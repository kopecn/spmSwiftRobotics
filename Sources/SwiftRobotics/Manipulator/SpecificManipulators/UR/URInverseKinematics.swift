import simd

public struct URInverseKinematics {

    let d6: Double
    let d6Vect: simd_double4
    let d4: Double
    let d4Vect: simd_double4
    let l1: KinematicLinkDH
    let l2: KinematicLinkDH
    let l3: KinematicLinkDH
    let l5: KinematicLinkDH
    let l6: KinematicLinkDH
    let a2: Double
    let a3: Double

    let vectAdj = simd_double4(0, 0, 0, 1)

    var vector0to5: SIMD4<Double> = SIMD4(0, 0, 0, 0)
    var psi: Double = 0
    var phi: Double = 0
    var transform6to1: simd_double4x4 = matrix_identity_double4x4
    var transform1to6: simd_double4x4 = matrix_identity_double4x4
    var transform1to4: simd_double4x4 = matrix_identity_double4x4
    var vector1to3: SIMD4<Double> = SIMD4(0, 0, 0, 0)

    var vector1to6z: Double = 0
    var sinTheta5: Double = 0

    var theta1: Double = 0
    var theta2: Double = 0
    var theta3: Double = 0
    var theta4: Double = 0
    var theta5: Double = 0
    var theta6: Double = 0

    public init(
        link1: KinematicLinkDH,
        link2: KinematicLinkDH,
        link3: KinematicLinkDH,
        link4: KinematicLinkDH,
        link5: KinematicLinkDH,
        link6: KinematicLinkDH,
    ) {
        l1 = link1
        l2 = link3
        l5 = link5
        l6 = link6
        a2 = link2.a
        a3 = link3.a
        l3 = link3
        d4 = link4.d
        d6 = link6.d
        d6Vect = simd_double4(0, 0, -link6.d, 1)
        d4Vect = simd_double4(0, -link4.d, 0, 1)
    }

    /// ψ = atan2 ((P05 )y,(P05 )x)
    /// Note, if is not a number, isNaN, then the IK cannot be computed.
    /// isNaN will only occur for UR robot if the 0->5 vector has no
    /// X or Y components.
    private var getPsi: Double {
        /// ψ= atan2 (P05 )y,(P05 )x
        atan2(vector0to5[1], vector0to5[0])
    }

    /// φ= ±arccos (d4 / (P05 )xy)
    /// Note, if is not a number, isNaN, then the IK cannot be computed.
    /// isNaN will only occur for UR robot if the 0->5 vector onto the
    /// X-Y plane is smaller than d4... e.g. the donut hole
    private var getPhi: Double {
        acos(
            d4 / sqrt(pow(vector0to5[0], 2) + pow(vector0to5[1], 2))
        )
    }

    private func vector1to6z(
        pose: simd_double4x4,
        theta1: Double
    ) -> Double {
        return pose[3][0] * sin(theta1) - pose[3][1] * cos(theta1)
    }

    private func getTheta1(
        whichPose: URRobotPostureType
    ) -> Double {
        if whichPose.shoulderLeft {
            return psi + phi + Double.pi / 2
        } else {
            return psi - phi + Double.pi / 2
        }
    }

    private func getTheta2(
        theta3: Double
    ) -> Double {
        -atan2(
            self.vector1to3[1], -self.vector1to3[0]
        ) + asin(
            (self.a3 * sin(self.theta3)) / simd_length(self.vector1to3)
        )
    }

    private func getTheta3(whichPose: URRobotPostureType) -> Double {

        if whichPose.wristUp {
            return acos(
                (simd_length_squared(self.vector1to3) - pow(a2, 2) - pow(a3, 2)) / (2 * a2 * a3)
            )
        } else {
            return -acos(
                (simd_length_squared(self.vector1to3) - pow(a2, 2) - pow(a3, 2)) / (2 * a2 * a3)
            )
        }
    }

    private func getTheta4(
        transform3to4: simd_double4x4
    ) -> Double {
        atan2(transform3to4[1, 0], transform3to4[0, 0])
    }

    /// Notes: θ6 is not well-defined when sin(θ5) = 0 or when zx,zy = 0
    private func getTheta5(
        whichPose: URRobotPostureType
    ) -> Double {
        if whichPose.wristUp {
            return acos((self.vector1to6z - self.d4) / self.d6)
        } else {
            return -acos((self.vector1to6z - self.d4) / self.d6)
        }
    }

    private func getTheta6(transform1to6: simd_double4x4) -> Double {
        /// zy zx
        // print("\(-transform1to6[2, 1]) / \(self.sinTheta5), \(transform1to6[2, 0])")
        return atan2(-transform1to6[2, 1] / self.sinTheta5, transform1to6[2, 0] / self.sinTheta5)
    }

    private func vector0to5(
        pose: simd_double4x4
    ) -> SIMD4<Double> {
        return pose * d6Vect - vectAdj
    }

    /// Computes the inverse kinematics for the UR manipulator.
    public mutating func computePostureFor(
        pose: PoseRobot,
        whichPose: URRobotPostureType,
        jointWrap: (Int, Int, Int, Int, Int, Int, Int, Int),
    ) -> PostureSerialRobot? {
        print("------")

        self.vector0to5 = vector0to5(pose: pose.pose)
        print("vector0to5: \(vector0to5), d6: \(d6)")

        self.psi = self.getPsi
        self.phi = self.getPhi
        print("psi: \(psi), phi: \(phi)")

        if psi.isNaN || phi.isNaN {
            return nil
        }

        /// The two solutions for θ1 above correspond to the shoulder
        /// being either "left" or "right,".
        self.theta1 = getTheta1(whichPose: whichPose)

        self.vector1to6z = vector1to6z(pose: pose.pose, theta1: theta1)
        print("vector1to6z: \(vector1to6z)")

        /// there are two solutions.
        /// These solutions correspond to the wrist being "down" and "up."
        self.theta5 = getTheta5(whichPose: whichPose)
        print("theta1: \(theta1), theta5: \(theta5)")

        if self.theta5.isNaN {
            return nil
        }

        self.sinTheta5 = sin(self.theta5)

        // Compute T_16 (transform from frame 1 to frame 6) for theta6 calculation
        self.transform1to6 = l1.getPose(theta: theta1).inverse * pose.pose
        self.transform6to1 = self.transform1to6.inverse
        self.theta6 = getTheta6(transform1to6: transform6to1)



        self.transform1to4 = self.transform1to6 * (l5.getPose(theta: theta5) * l6.getPose(theta: self.theta6)).inverse

        self.vector1to3 = self.transform1to4 * d4Vect - vectAdj

        /// there are two solutions for θ2 and θ3.
        /// These solutions are known as “elbow up” and “elbow down.”
        self.theta3 = getTheta3(whichPose: whichPose)
        print("theta3: \(theta3), theta6: \(theta6)")

        if self.theta3.isNaN {
            return nil
        }

        self.theta2 = getTheta2(
            theta3: self.theta3
        )

        self.theta4 = getTheta4(
            transform3to4: (l2.getPose(theta: self.theta2) * l3.getPose(theta: self.theta3)).inverse
                * self.transform1to4
        )
        print("theta2: \(theta2), theta4: \(theta4)")

        return PostureSerialRobot(
            jointAngles: [theta1, theta2, theta3, theta4, theta5, theta6]
        )
    }
}

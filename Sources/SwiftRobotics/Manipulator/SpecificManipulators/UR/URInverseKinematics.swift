import simd

public struct URInverseKinematics {

    let d6: Double
    let d4: Double
    let l1: KinematicLinkDH
    let l2: KinematicLinkDH
    let l3: KinematicLinkDH
    let a2: Double
    let a3: Double

    var vector0to5: SIMD4<Double> = SIMD4(0, 0, 0, 0)
    var psi: Double = 0
    var phi: Double = 0
    var transform1to6: simd_double4x4 = matrix_identity_double4x4
    var transform5to6: simd_double4x4 = matrix_identity_double4x4
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
        a2 = link2.a
        a3 = link3.a
        l3 = link3
        d4 = link4.d
        d6 = link6.d
    }

    /// ψ = atan2 ((P05 )y,(P05 )x)
    /// Note, if is not a number, isNaN, then the IK cannot be computed.
    /// isNaN will only occur for UR robot if the 0->5 vector has no
    /// X or Y components.
    private var getPsi: Double {
        /// ψ= atan2 (P05 )y,(P05 )x
        atan2(vector0to5[0], vector0to5[1])
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
        theta: Double
    ) -> Double {
        pose[0][3] * sin(theta) + pose[1][3] * cos(theta)
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
            self.vector1to3[1],
            -self.vector1to3[0]
        )
            + asin(
                self.a3 * sin(self.theta3) * simd_length(self.vector1to3)
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
            return acos((self.vector1to6z - d4) / d6)
        } else {
            return -acos((self.vector1to6z - d4) / d6)
        }
    }

    private func getTheta6(pose: simd_double4x4) -> Double {
        atan2(-pose[1, 2] / self.sinTheta5, pose[0, 2] / self.sinTheta5)
    }

    private func vector0to5(pose: simd_double4x4, d6: Double) -> SIMD4<Double> {
        pose * simd_double4(0, 0, -d6, 1) - simd_double4(0, 0, 0, 1)
    }

    /// Computes the inverse kinematics for the UR manipulator.
    public mutating func computePostureFor(
        pose: PoseRobot,
        whichPose: URRobotPostureType,
        jointWrap: (Int, Int, Int, Int, Int, Int, Int, Int),
    ) -> PostureSerialRobot? {

        self.vector0to5 = vector0to5(pose: pose.pose, d6: d6)

        self.psi = self.getPsi
        self.phi = self.getPhi

        if psi.isNaN || phi.isNaN {
            return nil
        }

        /// The two solutions for θ1 above correspond to the shoulder
        /// being either “left” or “right,”.
        self.theta1 = getTheta1(whichPose: whichPose)

        self.transform1to6 = (l1.getPose(theta: theta1).inverse * pose.pose).inverse

        self.vector1to6z = vector1to6z(pose: pose.pose, theta: theta1)

        /// there are two solutions.
        /// These solutions correspond to the wrist being “down” and “up.”
        self.theta5 = getTheta5(whichPose: whichPose)

        if self.theta5.isNaN {
            return nil
        }

        self.sinTheta5 = sin(self.theta5)

        self.theta6 = getTheta6(pose: pose.pose)

        self.transform5to6 = l1.getPose(theta: self.theta6)

        self.transform1to4 = self.transform1to6 * (l1.getPose(theta: theta5) * self.transform5to6).inverse

        self.vector1to3 = self.transform1to4 * simd_double4(0, -d4, 0, 1) - simd_double4(0, 0, 0, 1)

        /// there are two solutions for θ2 and θ3.
        /// These solutions are known as “elbow up” and “elbow down.”
        self.theta3 = getTheta3(whichPose: whichPose)

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

        return PostureSerialRobot(
            jointAngles: [theta1, theta2, theta3, theta4, theta5, theta6]
        )
    }
}

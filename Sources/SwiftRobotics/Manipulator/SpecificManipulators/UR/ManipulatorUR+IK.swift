import simd

extension ManipulatorUR {

    /// ψ
    /// Note, if is not a number, isNaN, then the IK cannot be computed.
    private func psi(vector0to5: SIMD4<Double> ) -> Double {
        /// ψ= atan2 (P05 )y,(P05 )x
        return atan2(vector0to5[0], vector0to5[1])
    }

    /// φ
    /// Note, if is not a number, isNaN, then the IK cannot be computed.
    private func phi(d4: Double, vector0to5: SIMD4<Double>) -> Double {
        return acos( 
            d4 / sqrt(pow(vector0to5[0], 2) + pow(vector0to5[1], 2))
        )
    }

    private func vector1to6z( pose: simd_double4x4, theta: Double ) -> Double {
        return pose[0][3] * sin(theta) + pose[1][3] * cos(theta)
    }

    private func theta5(
        vector1to6z: Double, 
        d4: Double,
        d6: Double
    ) -> Double {
        return acos( 
            ( vector1to6z - d4 ) / d6
        )
    }


    /// Computes the inverse kinematics for the UR manipulator.
    public func computePosturesFor(
        pose: PoseRobot,
        whichPose: URRobotPostureType,
        jointWrap: (Int, Int, Int, Int, Int, Int, Int, Int),
    ) -> [PostureSerialRobot] {

        guard 
        let d6 = (links[5] as? KinematicLinkDH)?.d,
        let d4 = (links[3] as? KinematicLinkDH)?.d
        else {
            return []
        }

        let vector0to5  = pose.pose * simd_double4(0,0,-d6,1) - simd_double4(0,0,0,1)

        let psi = self.psi(vector0to5: vector0to5)
        let phi = self.phi(d4: d4, vector0to5: vector0to5)

        if psi.isNaN || phi.isNaN {
            return []
        }

        let theta0Left = psi + phi + Double.pi
        let theta0Right = psi - phi + Double.pi

        // +/- correspond to the shoulder being either “left” or “right,”
        var jointAngles: [[Double]] = [
            [theta0Left,0,0,0,0,0], [theta0Left,0,0,0,0,0], [theta0Left,0,0,0,0,0], [theta0Left,0,0,0,0,0], 
            [theta0Right,0,0,0,0,0], [theta0Right,0,0,0,0,0], [theta0Right,0,0,0,0,0], [theta0Right,0,0,0,0,0], 
        ]

        let vector1to6zLeft = self.vector1to6z(pose: pose.pose, theta: theta0Left)
        let vector1to6zRight = self.vector1to6z(pose: pose.pose, theta: theta0Right)

        let theta5Left = theta5(vector1to6z: vector1to6zLeft, d4: d4, d6: d6)
        let theta5Right = theta5(vector1to6z: vector1to6zRight, d4: d4, d6: d6)

        if theta5Left.isNaN, theta5Right.isNaN {
            return []
        }

        if !theta5Left.isNaN {
            jointAngles[0][4] = theta5Left
            jointAngles[1][4] = theta5Left
            jointAngles[4][4] = theta5Left
            jointAngles[5][4] = theta5Left
        }

        if !theta5Left.isNaN {
            jointAngles[0][4] = theta5Right
            jointAngles[1][4] = theta5Right
            jointAngles[4][4] = theta5Right
            jointAngles[5][4] = theta5Right
        }

        return []
    }

    /// Computes the inverse kinematics for the UR manipulator.
    public func computePostureFor(
        pose: PoseRobot,
        whichPose: URRobotPostureType,
        jointWrap: (Int, Int, Int, Int, Int, Int, Int, Int),
    ) -> PostureSerialRobot? {
        return nil
    }
}
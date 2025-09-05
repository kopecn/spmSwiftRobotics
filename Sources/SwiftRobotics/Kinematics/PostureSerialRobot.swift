public class PostureSerialRobot {
    /// The posture of the robot, which includes the joint angles.
    public var jointAngles: [Double]

    /// Initializes a new RobotPosture with the given joint angles.
    /// - Parameter jointAngles: An array of joint angles representing the robot's posture.
    public init(jointAngles: [Double]) {
        self.jointAngles = jointAngles
    }

    /// Returns a string representation of the robot's posture.
    public var description: String {
        "RobotPosture(jointAngles: \(jointAngles))"
    }
}

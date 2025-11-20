/// Represents commands that can be sent to the UR robot's dashboard client.
///
/// Each case corresponds to a specific dashboard command supported by the robot.
enum URCommand: String {
    /// Initializes the robot.
    case initRobot
    /// Moves the robot to its home position.
    case home
    /// Requests the robot's version information.
    case ver
    /// Requests the robot's status.
    case status
    /// Requests the robot's current pose.
    case currentpose
    /// Requests the robot's current posture.
    case currentposture
    /// Starts streaming data from the robot.
    case startstreaming
    /// Stops streaming data from the robot.
    case stopstreaming

    /// Returns the string representation of the command to be sent to the dashboard client.
    var commandString: String {
        switch self {
        case .initRobot:
            return "initRobot"
        case .home:
            return "home"
        case .ver:
            return "ver"
        case .status:
            return "status"
        case .currentpose:
            return "currentpose"
        case .currentposture:
            return "currentposture"
        case .startstreaming:
            return "startstreaming"
        case .stopstreaming:
            return "stopstreaming"
        }
    }
}

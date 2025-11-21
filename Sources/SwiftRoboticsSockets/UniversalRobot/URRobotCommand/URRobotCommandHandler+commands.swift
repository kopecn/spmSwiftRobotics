import SwiftRobotics

/// Extension for `URRobotCommandHandler` providing high-level robot command methods.
/// These methods send formatted commands to the UR Command Client via a socket connection.
extension URRobotCommandHandler {

    /// Sends a formatted command to the robot using transaction protocol.
    /// - Parameter command: The `RobotCommand` to send.
    private func sendCommand(_ command: RobotCommand) {
        // TODO: Implement proper transaction ID management (increment, wrap at 899)
        guard let commandServerSocket = commandServerSocket else { return }
        let transactionID = "1"
        let msg = command.serialize(transactionID: transactionID)
        commandServerSocket.send(msg)
    }

    /// Initializes the robot by sending the `.initRobot` command.
    public func initRobot() {
        sendCommand(.initRobot)
    }

    /// Sends the `.home` command to move the robot to its home position.
    public func home() {
        sendCommand(.home)
    }

    /// Requests the robot's version information by sending the `.ver` command.
    public func ver() {
        sendCommand(.ver)
    }

    /// Requests the robot's status by sending the `.status` command.
    public func status() {
        sendCommand(.status)
    }

    /// Requests the robot's current pose by sending the `.currentpose` command.
    public func currentpose() {
        sendCommand(.currentpose)
    }

    /// Requests the robot's current posture by sending the `.currentposture` command.
    public func currentposture() {
        sendCommand(.currentposture)
    }

    /// Starts streaming data from the robot by sending the `.startstreaming` command.
    public func startstreaming() {
        sendCommand(.startstreaming)
    }

    /// Stops streaming data from the robot by sending the `.stopstreaming` command.
    public func stopstreaming() {
        sendCommand(.stopstreaming)
    }
}

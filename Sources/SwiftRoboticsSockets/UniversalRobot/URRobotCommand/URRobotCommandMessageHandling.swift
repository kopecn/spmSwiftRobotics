import SocketCommon

/// Handles messages received from the robot command client.
///
/// `URRobotCommandMessageHandling` is responsible for processing messages sent from the robot's dashboard.
/// It updates the associated `URRobotCommandHandler` with the latest dashboard response.
/// This class is marked as `@unchecked Sendable` because it holds a weak reference
/// to the `URRobotCommandHandler`, which is not `Sendable`. The weak reference
/// ensures no concurrency issues as the reference isn't strongly retained or mutated concurrently.
final class URRobotCommandMessageHandling: @unchecked Sendable, MessageHandling {

    /// A weak reference to the robot command handler delegate.
    private weak var delegate: URRobotCommandHandler?

    /// Initializes the message handler with a delegate.
    /// - Parameter delegate: The `URRobotCommandHandler` to receive message updates.
    init(delegate: URRobotCommandHandler) {
        self.delegate = delegate
    }

    /// Handles an incoming message from the robot command client.
    /// Updates the delegate's `lastResponse` property on the main actor.
    /// - Parameter message: The message string received from the robot.
    func handleMessage(_ message: String) async {
        await MainActor.run {
            logger.info("🟢 Recv: \(message)")
            delegate?.lastResponse = message
            // FIXME: - Add appropriate handler for transaction management.
        }
    }
}

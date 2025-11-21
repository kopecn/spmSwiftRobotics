import SocketCommon

/// Handles messages received from the robot stream client.
///
/// `URRobotStreamMessageHandling` is responsible for processing messages sent from the robot's streaming interface.
/// It updates the associated `URRobotStreamHandler` with the latest stream response.
/// This class is marked as `@unchecked Sendable` because it holds a weak reference
/// to the `URRobotStreamHandler`, which is not `Sendable`. The weak reference
/// ensures no concurrency issues as the reference isn't strongly retained or mutated concurrently.
final class URRobotStreamMessageHandling: @unchecked Sendable, MessageHandling {

    /// A weak reference to the robot stream handler delegate.
    private weak var delegate: URRobotStreamHandler?

    /// Initializes the message handler with a delegate.
    /// - Parameter delegate: The `URRobotStreamHandler` to receive message updates.
    init(delegate: URRobotStreamHandler) {
        self.delegate = delegate
    }

    /// Handles an incoming message from the robot stream interface.
    /// Updates the delegate's stream response property on the main actor.
    /// - Parameter message: The message string received from the robot.
    func handleMessage(_ message: String) async {
        await MainActor.run {
            logger.debug("🔵 Recv: \(message)")
            if message.contains("more") {
                if let postures = self.delegate?.currentlyLoadedWaveform?.dequeueURScriptFormat() {
                    self.delegate?.streamServerSocket?.send(postures)
                    logger.debug("🔵 Sending: \(postures)")
                }
            }
        }
    }
}

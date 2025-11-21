import SocketCommon

/// Handles messages received from the robot dashboard server.
///
/// This class is marked as `@unchecked Sendable` because it holds a weak reference
/// to the `URRobotDashboardHandler`, which is not `Sendable`. The weak reference
/// ensures no concurrency issues as the reference isn't strongly retained or mutated concurrently.
final class URRobotDashboardMessageHandling: @unchecked Sendable, MessageHandling {

    /// Weak reference to the dashboard handler delegate.
    private weak var delegate: URRobotDashboardHandler?

    /// Initializes the message handler with a delegate.
    /// - Parameter delegate: The dashboard handler to receive messages.
    init(delegate: URRobotDashboardHandler) {
        self.delegate = delegate
    }

    /// Handles an incoming message from the dashboard server.
    /// - Parameter message: The message received from the server.
    func handleMessage(_ message: String) async {
        await MainActor.run {
            logger.info("🟢 Recv: \(message)")
            delegate?.lastDashResponse = message
        }
    }
}

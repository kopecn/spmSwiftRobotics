import Foundation
import FoundationInterfaces
import SocketCommon

/// Handles messages received from the robot Primary server (port 30001).
///
/// This class is marked as `@unchecked Sendable` because it holds a weak reference
/// to the `URRobotScriptHandler`, which is not `Sendable`. The weak reference
/// ensures no concurrency issues as the reference isn't strongly retained or mutated concurrently.
final class URRobotScriptMessageHandling: @unchecked Sendable, MessageSendable, MessageReceivable {

    func send(to id: (any Identifiable)?, _ data: Data, _ priority: Int, _ queueIfDisconnected: Bool) -> Bool {
        false
    }

    func send(to id: (any Identifiable)?, _ message: String, _ priority: Int, _ queueIfDisconnected: Bool) -> Bool {
        false
    }

    func setDataMessageHandler(_ handler: (@Sendable (Data) -> Void)?) {

    }

    func setStringMessageHandler(_ handler: (@Sendable (String) -> Void)?) {

    }

    /// Weak reference to the URScript handler delegate.
    private weak var delegate: URRobotScriptHandler?

    /// Initializes the message handler with a delegate.
    /// - Parameter delegate: The URScript handler to receive messages.
    init(delegate: URRobotScriptHandler) {
        self.delegate = delegate
    }

    /// Handles an incoming message from the Primary server.
    /// - Parameter message: The message received from the server.
    func handleMessage(_ message: String) async {
        // Do nothing
    }
}

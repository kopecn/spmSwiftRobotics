import SocketCommon

/// Handles messages received from the robot Primary server (30001).
///
/// This class is marked as `@unchecked Sendable` because it holds a weak reference
/// to the `URRobotScriptMessageHandling`, which is not `Sendable`. The weak reference
/// ensures no concurrency issues as the reference isn't strongly retained or mutated concurrently.
final class URRobotScriptMessageHandling: @unchecked Sendable, MessageHandling {

    private weak var delegate: URRobotScriptHandler?

    init(delegate: URRobotScriptHandler) {
        self.delegate = delegate
    }

    func handleMessage(_ message: String) async {
        //Do nothing
    }
}

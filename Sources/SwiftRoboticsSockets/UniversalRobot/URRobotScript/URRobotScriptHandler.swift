import SwiftRoboticAssets
import Foundation
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon

/// Handles Universal Robot URScript client socket connections and message handling.
///
/// - Provides observable connection state for UI integration.
/// - Manages client lifecycle: connect, disconnect, error handling.
/// - Loads and sends URScript files to the robot.
/// - Integrates with NIOSocketHandlerClient and URRobotScriptMessageHandling.
public class URRobotScriptHandler: OpenCombine.ObservableObject {

    // MARK: - OpenCombine Compatibility for SwiftUI/SwiftCrossUI

    /// Publisher for object change notifications, compatible with OpenCombine.
    public let objectWillChange = ObservableObjectPublisher()

    /// Current connection state of the URScript client socket.
    @OpenCombine.Published public var connectionState: SocketClientConnectionState = .disconnected {
        didSet {
            objectWillChange.send()
        }
    }

    /// IP address used for the URScript client socket. Defaults to "localhost".
    public var ipAddress: String = "localhost"

    /// Port used for the URScript client socket. Defaults to 30001.
    private var port: Int = 30001

    /// Cancellable for connection state publisher subscription.
    private var connectionStateCancellable: AnyCancellable?

    /// Handler for incoming URScript messages.
    var urScriptMessageHandler: URRobotScriptMessageHandling?

    /// The client socket instance handling URScript communication.
    var urScriptClientSocket: NIOSocketHandlerClient?

    /// Initializes the URScript handler.
    public init() {
        logger.info("🟢 URRobotScriptHandler Handler Initialized ")
    }

    /// Toggles the connection state of the URScript client socket.
    /// - Connects if not connected, disconnects if active.
    public func toggleConnection() {
        guard let urScriptClientSocket = urScriptClientSocket else {
            logger.info("🟢 Connecting")
            connect()
            return
        }

        switch urScriptClientSocket.connectionStatePublisher.value {
        case .connected:
            logger.info("🟢 Disconnecting")
            disconnect()
        case .disconnected:
            logger.info("🟢 Connecting")
            connect()
        case .connecting, .disconnecting:
            logger.info("🟢 State transition, doing nothing")
        case .error(let error):
            logger.error(
                "🔴 Connection Error from Toggle, please clear error: \(error.localizedDescription)"
            )
        }
    }

    /// Connects to the URScript server.
    /// - Parameters:
    ///   - ipAddress: Optional IP address to override the default.
    ///   - port: Optional port to override the default.
    private func connect(
        ipAddress: String? = nil,
        port: Int? = nil
    ) {

        guard !(urScriptClientSocket?.isConnected ?? false) else { return }

        // Update properties if new values are provided
        if let newIpAddress = ipAddress {
            self.ipAddress = newIpAddress
        }
        if let newPort = port {
            self.port = newPort
        }

        connectionState = .connecting

        let scriptHandler = URRobotScriptMessageHandling(delegate: self)
        self.urScriptMessageHandler = scriptHandler

        urScriptClientSocket = NIOSocketHandlerClient()

        connectionStateCancellable = urScriptClientSocket?.connectionStatePublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink { [weak self] state in
                logger.debug("🔵 Socket state changed: \(state)")
                self?.connectionState = state
            }

        urScriptClientSocket?.connect(
            host: self.ipAddress,
            port: self.port,
            messageHandler: scriptHandler
        )
    }

    /// Tears down the client socket and cancels subscriptions.
    /// - Throws: Any error encountered during shutdown.
    private func teardown() throws {
        connectionStateCancellable?.cancel()
        try urScriptClientSocket?.shutdown()

        connectionStateCancellable = nil
        urScriptClientSocket = nil
        urScriptMessageHandler = nil
    }

    /// Disconnects the URScript client socket and updates state.
    private func disconnect() {
        guard urScriptClientSocket?.isConnected ?? false else { return }

        connectionState = .disconnecting

        do {
            try teardown()

            connectionState = .disconnected

            logger.info("🟢 \(self) disconnected")

        } catch {
            connectionState = .error(err: error)
        }
    }

    /// Clears any connection errors and resets state.
    public func clearConnectionError() {
        try? teardown()
        connectionState = .disconnected
    }

    /// Loads a URScript file from a custom path or bundle and sends it to the robot.
    /// - Parameter fromPath: Optional file path to load the URScript from.
    public func loadAndPushURScript(fromPath path: String? = nil) {
        let script: String?

        // Try to load from custom path if provided
        if let customPath = path, !customPath.isEmpty {
            let url = URL(fileURLWithPath: customPath)
            script = try? String(contentsOf: url, encoding: .utf8)
            if script != nil {
                logger.info("🟢 Loaded UR Script from custom path: \(customPath)")
            } else {
                logger.error("🔴 Failed to load UR Script from custom path: \(customPath)")
            }
        } else {
            // Fall back to bundle resource
            script = AssetLoader.loadURScript()
            if script != nil {
                logger.info("🟢 Loaded UR Script from bundle")
            } else {
                logger.error("🔴 Failed to load UR Script from bundle")
            }
        }

        if let script = script {
            urScriptClientSocket?.send(script)
        } else {
            logger.error("🔴 Failed to load the UR Script file")
        }
    }

    /// Handles incoming URScript messages.
    /// - Parameter input: The message received from the URScript server.
    private func handleURScriptMessages(_ input: String) async {
        logger.debug("🔵 Handled URScript input: \(input)")
    }
}

// MARK: - Logging Description

extension URRobotScriptHandler: CustomStringConvertible {
    /// String description for logging and debugging.
    public var description: String {
        "URRobotScriptHandler(connectionState: \(connectionState))"
    }
}

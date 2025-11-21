import SwiftRoboticAssets
import Foundation
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon

/// Handles Universal Robot dashboard client socket connections and message handling.
/// 
/// - Provides observable connection state for UI integration.
/// - Manages client lifecycle: connect, disconnect, error handling.
/// - Integrates with NIOSocketHandlerClient and URRobotDashboardMessageHandling.
public class URRobotDashboardHandler: OpenCombine.ObservableObject {

    // MARK: - OpenCombine Compatibility for SwiftUI/SwiftCrossUI

    /// Publisher for object change notifications, compatible with OpenCombine.
    public let objectWillChange = ObservableObjectPublisher()

    /// Current connection state of the dashboard client socket.
    @OpenCombine.Published public var connectionState: SocketClientConnectionState = .disconnected {
        didSet {
            objectWillChange.send()
        }
    }

    /// Last response received from the dashboard server.
    @OpenCombine.Published public var lastDashResponse: String = "" {
        didSet {
            objectWillChange.send()
        }
    }

    /// IP address used for the dashboard client socket. Defaults to "localhost".
    public var ipAddress: String = "localhost"

    /// Port used for the dashboard client socket. Defaults to 29999.
    private var port: Int = 29999

    /// Cancellable for connection state publisher subscription.
    private var connectionStateCancellable: AnyCancellable?

    /// Handler for incoming dashboard messages.
    var dashboardMessageHandler: URRobotDashboardMessageHandling?

    /// The client socket instance handling dashboard communication.
    var dashboardClientSocket: NIOSocketHandlerClient?

    /// Last dashboard command sent.
    var lastDashCommandSent: String = "None"

    /// Initializes the dashboard handler.
    public init() {
        logger.info("🟢 UR Robot Class Handler Initialized ")
    }

    /// Initializes the dashboard handler with custom IP address and port.
    /// - Parameters:
    ///   - ipAddress: The IP address of the robot dashboard server. Defaults to "localhost".
    ///   - port: The port of the dashboard server. Defaults to 29999.
    /// - Note: This is a convenience initializer for testing and custom configurations.
    ///         The default parameterless init() is preferred for reactive frontends.
    public init(ipAddress: String, port: Int = 29999) {
        self.ipAddress = ipAddress
        self.port = port
        logger.info("🟢 UR Robot Class Handler Initialized with IP: \(ipAddress), Port: \(port)")
    }

    /// Toggles the connection state of the dashboard client socket.
    /// - Connects if not connected, disconnects if active.
    public func toggleConnection() {
        guard let dashboardClientSocket = dashboardClientSocket else {
            logger.info("🟢 Connecting")
            connect()
            return
        }

        switch dashboardClientSocket.connectionStatePublisher.value {
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

    /// Connects to the dashboard server.
    /// - Parameters:
    ///   - ipAddress: Optional IP address to override the default.
    ///   - port: Optional port to override the default.
    private func connect(
        ipAddress: String? = nil,
        port: Int? = nil
    ) {

        guard !(dashboardClientSocket?.isConnected ?? false) else { return }

        // Update properties if new values are provided
        if let newIpAddress = ipAddress {
            self.ipAddress = newIpAddress
        }
        if let newPort = port {
            self.port = newPort
        }

        connectionState = .connecting

        let dashHandler = URRobotDashboardMessageHandling(delegate: self)
        self.dashboardMessageHandler = dashHandler

        dashboardClientSocket = NIOSocketHandlerClient()

        connectionStateCancellable = dashboardClientSocket?.connectionStatePublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink { [weak self] state in
                logger.debug("🔵 Socket state changed: \(state)")
                self?.connectionState = state
            }

        dashboardClientSocket?.connect(
            host: self.ipAddress,
            port: self.port,
            messageHandler: dashHandler
        )
    }

    /// Tears down the client socket and cancels subscriptions.
    /// - Throws: Any error encountered during shutdown.
    private func teardown() throws {
        connectionStateCancellable?.cancel()
        try dashboardClientSocket?.shutdown()

        connectionStateCancellable = nil
        dashboardClientSocket = nil
        dashboardMessageHandler = nil
    }

    /// Disconnects the dashboard client socket and updates state.
    private func disconnect() {
        guard dashboardClientSocket?.isConnected ?? false else { return }

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

    /// Handles incoming dashboard messages.
    /// - Parameter input: The message received from the dashboard server.
    private func handleDashboardMessages(_ input: String) async {
        logger.debug("🔵 Handled dashboard input: \(input)")
    }
}

// MARK: - Logging Description

extension URRobotDashboardHandler: CustomStringConvertible {
    public var description: String {
        "URRobotDashboardHandler(connectionState: \(connectionState))"
    }
}

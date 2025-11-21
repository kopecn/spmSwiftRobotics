import SwiftRoboticAssets
import Foundation
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon

/// Handles Universal Robot command server socket connections and message handling.
/// 
/// - Provides observable connection state for UI integration.
/// - Manages server lifecycle: start, stop, error handling.
/// - Integrates with NIOSocketHandlerServer and URRobotCommandMessageHandling.
public class URRobotCommandHandler: OpenCombine.ObservableObject {

    // MARK: - OpenCombine Compatibility for SwiftUI/SwiftCrossUI

    /// Publisher for object change notifications, compatible with OpenCombine.
    public let objectWillChange = ObservableObjectPublisher()

    /// Current connection state of the command server socket.
    @OpenCombine.Published public var connectionState: SocketServerListeningState = .off {
        didSet {
            objectWillChange.send()
        }
    }

    /// Port used for the command server socket. Defaults to 50001.
    private var port: Int = 50001

    /// Cancellable for connection state publisher subscription.
    private var connectionStateCancellable: AnyCancellable?

    /// Handler for incoming robot command messages.
    var commandMessageHandler: URRobotCommandMessageHandling?

    /// The server socket instance handling robot commands.
    var commandServerSocket: NIOSocketHandlerServer?

    /// Initializes the handler.
    /// - Parameter connectOnLaunch: If true, starts listening immediately.
    public init(
        connectOnLaunch: Bool = false
    ) {
        logger.info("🟢 UR Robot Class Handler Initialized ")
        if connectOnLaunch {
            self.startListening()
        }
    }

    /// Toggles the connection state of the command server socket.
    /// - Starts listening if not connected, disconnects if active.
    public func toggleConnection() {
        guard let commandServerSocket = commandServerSocket else {
            logger.info("🟢 Starting Server")
            startListening()
            return
        }

        switch commandServerSocket.serverConnectionStatePublisher.value {
        case .listening, .activeConnections:
            logger.info("🟢 Disconnecting")
            disconnect()
        case .off:
            logger.info("🟢 Connecting")
            startListening()
        case .shuttingDown:
            logger.info("🟢 State transition, doing nothing")
        case .error(let error):
            logger.error(
                "🔴 Listening Error from Toggle, please clear error: \(error.localizedDescription)"
            )
        }
    }

    /// Starts listening for robot command connections.
    /// - Parameter port: Optional port to override the default.
    private func startListening(
        port: Int? = nil
    ) {

        guard !(commandServerSocket?.serverConnectionStatePublisher.value ?? .off == .activeConnections) else { return }

        // Update properties if new values are provided
        if let newPort = port {
            self.port = newPort
        }

        let commandMessageHandler = URRobotCommandMessageHandling(delegate: self)

        self.commandMessageHandler = commandMessageHandler

        commandServerSocket = NIOSocketHandlerServer()

        connectionStateCancellable = commandServerSocket?.serverConnectionStatePublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink { [weak self] state in
                logger.debug("🔵 Socket state changed: \(state)")
                self?.connectionState = state
            }

        commandServerSocket?.listen(
            port: self.port,
            messageHandler: commandMessageHandler
        )
    }

    /// Tears down the server socket and cancels subscriptions.
    private func teardown() {
        connectionStateCancellable?.cancel()
        commandServerSocket?.shutdown()

        connectionStateCancellable = nil
        commandServerSocket = nil
        commandMessageHandler = nil
    }

    /// Disconnects the command server socket and updates state.
    private func disconnect() {

        guard commandServerSocket?.serverConnectionStatePublisher.value ?? .off != .off else { return }

        connectionState = .shuttingDown

        teardown()

        connectionState = .off

        logger.info("🟢 \(self) disconnected")
    }

    /// Clears any connection errors and resets state.
    public func clearConnectionError() {
        teardown()
        connectionState = .off
    }
}

// MARK: - Logging Description

extension URRobotCommandHandler: CustomStringConvertible {
    /// String description for logging and debugging.
    public var description: String {
        "URRobotCommandHandler(connectionState: \(connectionState))"
    }
}

import Foundation
import FoundationTransactions
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon
import SwiftRoboticAssets
import SwiftRobotics

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

    /// Last response received from the robot.
    @OpenCombine.Published public var lastResponse: String = "" {
        didSet {
            objectWillChange.send()
        }
    }

    /// Port used for the command server socket. Defaults to ``URNetworkConfiguration/commandPort``.
    private var port: Int = URNetworkConfiguration.commandPort

    /// Cancellable for connection state publisher subscription.
    private var connectionStateCancellable: AnyCancellable?

    /// Handler for incoming robot command messages.
    let transactionHandler: TransactionHandler<URRobotCommands>
    var commandMessageHandler: URRobotCommandMessageHandling?

    /// The server socket instance handling robot commands.
    var commandServerSocket: NIOSocketHandlerServer?

    /// Initializes the handler.
    /// - Parameter connectOnLaunch: If true, starts listening immediately.
    public init(
        connectOnLaunch: Bool = false,
        resourceID: String? = nil
    ) {
        logger.info("🟢 UR Robot Class Handler Initialized ")
        self.transactionHandler = TransactionHandler<URRobotCommands>(
            resourceID: resourceID ?? UUID().uuidString
        )
        configureMessageParser()

        if connectOnLaunch {
            self.startListening()
        }
    }

    /// Initializes the handler with custom port.
    /// - Parameters:
    ///   - port: The port to listen on for robot command connections. Defaults to ``URNetworkConfiguration/commandPort``.
    ///   - connectOnLaunch: If true, starts listening immediately.
    /// - Note: This is a convenience initializer for testing and custom configurations.
    ///         The default parameterless init() is preferred for reactive frontends.
    public init(
        port: Int,
        connectOnLaunch: Bool = false,
        resourceID: String? = nil
    ) {
        self.port = port
        logger.info("🟢 UR Robot Class Handler Initialized with Port: \(port)")

        self.transactionHandler = TransactionHandler<URRobotCommands>(
            resourceID: resourceID ?? UUID().uuidString
        )
        configureMessageParser()

        if connectOnLaunch {
            self.startListening()
        }
    }

    /// Configures the message parser on the transaction handler.
    ///
    /// Parses UR protocol messages in the format `<trID,type,code[,verbiage]>` where:
    /// - `type` is `ack`, `res`, or `evt`
    /// - `code` indicates success (0) or error (1/2)
    /// - `verbiage` is an optional human-readable message
    private func configureMessageParser() {
        transactionHandler.messageParser = { handler, message in
            guard let parsed = URProtocolMessageParser.parse(message) else {
                logger.warning("🟡 Unparseable message: \(message)")
                return
            }

            switch parsed.type {
            case .ack:
                if parsed.code == 0, let trID = parsed.trID {
                    handler.processAcknowledgment(transactionID: trID)
                } else if let trID = parsed.trID {
                    handler.processError(
                        transactionID: trID,
                        message: parsed.verbiage ?? "ACK error (code \(parsed.code))"
                    )
                }

            case .res:
                if parsed.code == 0, let trID = parsed.trID {
                    handler.processResponse(transactionID: trID, response: parsed.verbiage)
                } else if let trID = parsed.trID {
                    handler.processError(
                        transactionID: trID,
                        message: parsed.verbiage ?? "Response error (code \(parsed.code))"
                    )
                }

            case .evt:
                if let trID = parsed.trID, trID >= 0 {
                    handler.processEvent(code: parsed.code, payload: parsed.verbiage, transactionID: trID)
                } else {
                    handler.processEvent(code: parsed.code, payload: parsed.verbiage)
                }

            case .unknown(let typeStr):
                logger.warning("🟡 Unknown message type '\(typeStr)': \(message)")
            }
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

        guard (commandServerSocket?.serverConnectionStatePublisher.value ?? .off) != .activeConnections else { return }

        // Update properties if new values are provided
        if let newPort = port {
            self.port = newPort
        }

        let commandMessageHandler = URRobotCommandMessageHandling(delegate: self)

        self.commandMessageHandler = commandMessageHandler

        let socket = NIOSocketHandlerServer()
        commandServerSocket = socket

        transactionHandler.attachPipe(socket)

        connectionStateCancellable = commandServerSocket?.serverConnectionStatePublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink { [weak self] state in
                logger.debug("🔵 Socket state changed: \(state)")
                self?.connectionState = state

                switch state {
                case .activeConnections:
                    self?.transactionHandler.updateResourceState(.idle)
                case .off, .error:
                    self?.transactionHandler.updateResourceState(.disconnected)
                default:
                    break
                }
            }

        commandServerSocket?.listen(
            port: self.port,
            messageHandler: commandMessageHandler
        )
    }

    /// Tears down the server socket and cancels subscriptions.
    private func teardown() {
        transactionHandler.detachPipe()
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

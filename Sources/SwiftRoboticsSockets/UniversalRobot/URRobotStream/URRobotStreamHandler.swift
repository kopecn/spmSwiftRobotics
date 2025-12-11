import Foundation
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon
import SwiftRoboticAssets

/// Handles Universal Robot stream server socket connections and message handling.
///
/// - Provides observable connection state for UI integration.
/// - Manages server lifecycle: start, stop, error handling.
/// - Integrates with NIOSocketHandlerServer and URRobotStreamMessageHandling.
/// - Supports waveform streaming to the robot.
public class URRobotStreamHandler: OpenCombine.ObservableObject {

    // MARK: - OpenCombine Compatibility for SwiftUI/SwiftCrossUI

    /// Publisher for object change notifications, compatible with OpenCombine.
    public let objectWillChange = ObservableObjectPublisher()

    /// Current connection state of the stream server socket.
    @OpenCombine.Published public var connectionState: SocketServerListeningState = .off {
        didSet {
            objectWillChange.send()
        }
    }

    /// Port used for the stream server socket. Defaults to 50002.
    private var port: Int = 50002

    /// Cancellable for connection state publisher subscription.
    private var connectionStateCancellable: AnyCancellable?

    /// Handler for incoming stream messages.
    var streamMessageHandler: URRobotStreamMessageHandling?

    /// The server socket instance handling stream communication.
    var streamServerSocket: NIOSocketHandlerServer?

    /// The currently loaded waveform for streaming.
    var currentlyLoadedWaveform: WaveformStreamer?

    /// Initializes the stream handler.
    /// - Parameter connectOnLaunch: If true, starts listening immediately.
    public init(
        connectOnLaunch: Bool = false
    ) {
        logger.info("🟢 UR Robot Class Handler Initialized ")
        if connectOnLaunch {
            self.startListening()
        }
    }

    /// Initializes the stream handler with custom port.
    /// - Parameters:
    ///   - port: The port to listen on for robot stream connections. Defaults to 50002.
    ///   - connectOnLaunch: If true, starts listening immediately.
    /// - Note: This is a convenience initializer for testing and custom configurations.
    ///         The default parameterless init() is preferred for reactive frontends.
    public init(port: Int, connectOnLaunch: Bool = false) {
        self.port = port
        logger.info("🟢 UR Robot Class Handler Initialized with Port: \(port)")
        if connectOnLaunch {
            self.startListening()
        }
    }

    /// Toggles the connection state of the stream server socket.
    /// - Starts listening if not connected, disconnects if active.
    public func toggleConnection() {
        guard let streamServerSocket = streamServerSocket else {
            logger.info("🟢 Starting Server")
            startListening()
            return
        }

        switch streamServerSocket.serverConnectionStatePublisher.value {
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

    /// Starts listening for stream connections.
    /// - Parameter port: Optional port to override the default.
    private func startListening(
        port: Int? = nil
    ) {

        guard !(streamServerSocket?.serverConnectionStatePublisher.value ?? .off == .activeConnections) else { return }

        // Update properties if new values are provided
        if let newPort = port {
            self.port = newPort
        }

        let streamMessageHandler = URRobotStreamMessageHandling(delegate: self)

        self.streamMessageHandler = streamMessageHandler

        streamServerSocket = NIOSocketHandlerServer()

        connectionStateCancellable = streamServerSocket?.serverConnectionStatePublisher
            .receive(on: DispatchQueue.main.ocombine)
            .sink { [weak self] state in
                logger.debug("🔵 Socket state changed: \(state)")
                self?.connectionState = state
            }

        streamServerSocket?.listen(
            port: self.port,
            messageHandler: streamMessageHandler
        )
    }

    /// Tears down the server socket and cancels subscriptions.
    private func teardown() {
        connectionStateCancellable?.cancel()
        streamServerSocket?.shutdown()

        connectionStateCancellable = nil
        streamServerSocket = nil
        streamMessageHandler = nil
    }

    /// Disconnects the stream server socket and updates state.
    private func disconnect() {

        guard streamServerSocket?.serverConnectionStatePublisher.value ?? .off != .off else { return }

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

extension URRobotStreamHandler: CustomStringConvertible {
    /// String description for logging and debugging.
    public var description: String {
        "URRobotStreamHandler(connectionState: \(connectionState))"
    }
}

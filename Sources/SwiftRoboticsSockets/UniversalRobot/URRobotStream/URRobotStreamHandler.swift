import SwiftRoboticAssets
import Foundation
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon

public class URRobotStreamHandler: OpenCombine.ObservableObject {

    // MARK: - OpenCombine Compatibility for SwiftUI/SwiftCrossUI

    public let objectWillChange = ObservableObjectPublisher()

    @OpenCombine.Published public var connectionState: SocketServerListeningState = .off {
        didSet {
            objectWillChange.send()
        }
    }

    private var port: Int = 50002

    private var connectionStateCancellable: AnyCancellable?

    var streamMessageHandler: URRobotStreamMessageHandling?
    var streamServerSocket: NIOSocketHandlerServer?

    var currentlyLoadedWaveform: WaveformStreamer?

    public init(
        connectOnLaunch: Bool = false
    ) {
        logger.info("🟢 UR Robot Class Handler Initialized ")
        if connectOnLaunch {
            self.startListening()
        }
    }

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

    private func teardown() {
        connectionStateCancellable?.cancel()
        streamServerSocket?.shutdown()

        connectionStateCancellable = nil
        streamServerSocket = nil
        streamMessageHandler = nil
    }

    private func disconnect() {

        guard streamServerSocket?.serverConnectionStatePublisher.value ?? .off != .off else { return }

        connectionState = .shuttingDown

        teardown()

        connectionState = .off

        logger.info("🟢 \(self) disconnected")
    }

    public func clearConnectionError() {
        teardown()
        connectionState = .off
    }
}

// MARK: - Logging Description

extension URRobotStreamHandler: CustomStringConvertible {
    public var description: String {
        "URRobotStreamHandler(connectionState: \(connectionState))"
    }
}

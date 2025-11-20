import SwiftRoboticAssets
import Foundation
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon

public class URRobotCommandHandler: OpenCombine.ObservableObject {

    // MARK: - OpenCombine Compatibility for SwiftUI/SwiftCrossUI

    public let objectWillChange = ObservableObjectPublisher()

    @OpenCombine.Published public var connectionState: SocketServerListeningState = .off {
        didSet {
            objectWillChange.send()
        }
    }

    private var port: Int = 50001

    private var connectionStateCancellable: AnyCancellable?

    var commandMessageHandler: URRobotCommandMessageHandling?
    var commandServerSocket: NIOSocketHandlerServer?

    public init(
        connectOnLaunch: Bool = false
    ) {
        logger.info("🟢 UR Robot Class Handler Initialized ")
        if connectOnLaunch {
            self.startListening()
        }
    }

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

    private func teardown() {
        connectionStateCancellable?.cancel()
        commandServerSocket?.shutdown()

        connectionStateCancellable = nil
        commandServerSocket = nil
        commandMessageHandler = nil
    }

    private func disconnect() {

        guard commandServerSocket?.serverConnectionStatePublisher.value ?? .off != .off else { return }

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

extension URRobotCommandHandler: CustomStringConvertible {
    public var description: String {
        "URRobotCommandHandler(connectionState: \(connectionState))"
    }
}

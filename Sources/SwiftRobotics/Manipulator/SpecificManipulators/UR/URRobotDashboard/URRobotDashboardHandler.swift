import SwiftRoboticAssets
import Foundation
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon

public class URRobotDashboardHandler: OpenCombine.ObservableObject {

    // MARK: - OpenCombine Compatibility for SwiftUI/SwiftCrossUI

    public let objectWillChange = ObservableObjectPublisher()

    @OpenCombine.Published public var connectionState: SocketClientConnectionState = .disconnected {
        didSet {
            objectWillChange.send()
        }
    }

    @OpenCombine.Published public var lastDashResponse: String = "" {
        didSet {
            objectWillChange.send()
        }
    }

    public var ipAddress: String = "localhost"
    private var port: Int = 29999

    private var connectionStateCancellable: AnyCancellable?

    var dashboardMessageHandler: URRobotDashboardMessageHandling?
    var dashboardClientSocket: NIOSocketHandlerClient?

    var lastDashCommandSent: String = "None"

    public init() {
        logger.info("🟢 UR Robot Class Handler Initialized ")
    }

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

    private func teardown() throws {
        connectionStateCancellable?.cancel()
        try dashboardClientSocket?.shutdown()

        connectionStateCancellable = nil
        dashboardClientSocket = nil
        dashboardMessageHandler = nil
    }

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

    public func clearConnectionError() {
        try? teardown()
        connectionState = .disconnected
    }

    private func handleDashboardMessages(_ input: String) async {
        print("Handled input: \(input)")
    }
}

// MARK: - Logging Description

extension URRobotDashboardHandler: CustomStringConvertible {
    public var description: String {
        "URRobotDashboardHandler(connectionState: \(connectionState))"
    }
}

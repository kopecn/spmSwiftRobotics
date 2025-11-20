import SwiftRoboticAssets
import Foundation
import Logging
import NIOHandler
import OpenCombine
import OpenCombineDispatch
import SocketCommon

public class URRobotScriptHandler: OpenCombine.ObservableObject {

    // MARK: - OpenCombine Compatibility for SwiftUI/SwiftCrossUI

    public let objectWillChange = ObservableObjectPublisher()

    @OpenCombine.Published public var connectionState: SocketClientConnectionState = .disconnected {
        didSet {
            objectWillChange.send()
        }
    }

    public var ipAddress: String = "localhost"

    private var port: Int = 30001

    private var connectionStateCancellable: AnyCancellable?

    var urScriptMessageHandler: URRobotScriptMessageHandling?
    var urScriptClientSocket: NIOSocketHandlerClient?

    public init() {
        logger.info("🟢 URRobotScriptHandler Handler Initialized ")
    }

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

    private func teardown() throws {
        connectionStateCancellable?.cancel()
        try urScriptClientSocket?.shutdown()

        connectionStateCancellable = nil
        urScriptClientSocket = nil
        urScriptMessageHandler = nil
    }

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

    public func clearConnectionError() {
        try? teardown()
        connectionState = .disconnected
    }

    public func loadAndPushURScript(fromPath path: String? = nil) {
        let script: String?

        // Try to load from custom path if provided
        if let customPath = path, !customPath.isEmpty {
            let url = URL(fileURLWithPath: customPath)
            script = try? String(contentsOf: url, encoding: .utf8)
            if script != nil {
                print("Loaded UR Script from custom path: \(customPath)")
            } else {
                print("Failed to load UR Script from custom path: \(customPath)")
            }
        } else {
            // Fall back to bundle resource
            script = AssetLoader.loadURScript()
            if script != nil {
                print("Loaded UR Script from bundle")
            } else {
                print("Failed to load UR Script from bundle")
            }
        }

        if let script = script {
            urScriptClientSocket?.send(script)
        } else {
            print("Failed to load the UR Script file")
        }
    }

    private func handleURScriptMessages(_ input: String) async {
        print("Handled input: \(input)")
    }
}

// MARK: - Logging Description

extension URRobotScriptHandler: CustomStringConvertible {
    public var description: String {
        "URRobotScriptHandler(connectionState: \(connectionState))"
    }
}

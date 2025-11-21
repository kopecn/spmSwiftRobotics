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

    /// IP address for robot callbacks (used in urScript template replacement).
    /// When set, the <<HOST_CALLBACK_IPADDRESS>> placeholder in urScript will be replaced with this value.
    /// If nil, the placeholder will be replaced with the local machine's IP address (auto-detected).
    /// Defaults to nil (auto-detection).
    public var callbackIPAddress: String? = nil

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

    /// Initializes the URScript handler with custom IP address and port.
    /// - Parameters:
    ///   - ipAddress: The IP address of the robot URScript server. Defaults to "localhost".
    ///   - port: The port of the URScript server. Defaults to 30001.
    /// - Note: This is a convenience initializer for testing and custom configurations.
    ///         The default parameterless init() is preferred for reactive frontends.
    public init(ipAddress: String, port: Int = 30001) {
        self.ipAddress = ipAddress
        self.port = port
        logger.info("🟢 URRobotScriptHandler Handler Initialized with IP: \(ipAddress), Port: \(port)")
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
    ///
    /// If the loaded script contains the placeholder `<<HOST_CALLBACK_IPADDRESS>>`, it will be
    /// automatically replaced with the callback IP address (either from the `callbackIPAddress`
    /// property or auto-detected from the local machine).
    public func loadAndPushURScript(fromPath path: String? = nil) {
        var script: String?

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

        guard var finalScript = script else {
            logger.error("🔴 Failed to load the UR Script file")
            return
        }

        // Replace callback IP address placeholder if present
        let placeholder = "<<HOST_CALLBACK_IPADDRESS>>"
        if finalScript.contains(placeholder) {
            // Use explicit callback IP if set, otherwise try to auto-detect
            let replacementIP: String
            if let explicitIP = callbackIPAddress {
                replacementIP = explicitIP
                logger.info("🟢 Using explicit callback IP: \(replacementIP)")
            } else {
                // Attempt to auto-detect local IP address
                do {
                    replacementIP = try getLocalIPAddress()
                    logger.info("🟢 Auto-detected callback IP: \(replacementIP)")
                } catch {
                    logger.error("🔴 Failed to auto-detect callback IP: \(error.localizedDescription)")
                    logger.warning("⚠️  Sending script without IP replacement")
                    urScriptClientSocket?.send(finalScript)
                    return
                }
            }

            finalScript = finalScript.replacingOccurrences(of: placeholder, with: replacementIP)
            logger.info("✅ Replaced \(placeholder) with \(replacementIP)")
        }

        urScriptClientSocket?.send(finalScript)
    }

    /// Gets the local IP address of this machine.
    /// - Returns: The local IP address (e.g., "192.168.1.100")
    /// - Throws: Error if IP cannot be determined
    private func getLocalIPAddress() throws -> String {
        var address: String?

        // Get list of all interfaces on the local machine
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            throw URScriptError.cannotGetInterfaces
        }
        defer { freeifaddrs(ifaddr) }

        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }

            guard let interface = ptr?.pointee else { continue }

            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {  // IPv4 only

                // Interface name
                let name = String(cString: interface.ifa_name)

                // Only consider WiFi (en0) and Ethernet (en1, en2)
                guard name.hasPrefix("en") else { continue }

                // Convert interface address to a human readable string
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(
                    interface.ifa_addr,
                    socklen_t(interface.ifa_addr.pointee.sa_len),
                    &hostname,
                    socklen_t(hostname.count),
                    nil,
                    socklen_t(0),
                    NI_NUMERICHOST
                )

                let ipAddress = String(cString: hostname)

                // Skip loopback
                guard !ipAddress.hasPrefix("127.") else { continue }
                address = ipAddress
                break  // Found IPv4, use it
            }
        }

        guard let finalAddress = address else {
            throw URScriptError.noIPAddressFound
        }

        return finalAddress
    }

    /// Handles incoming URScript messages.
    /// - Parameter input: The message received from the URScript server.
    private func handleURScriptMessages(_ input: String) async {
        logger.debug("🔵 Handled URScript input: \(input)")
    }
}

// MARK: - URScript Errors

/// Errors that can occur during URScript processing
public enum URScriptError: Error, CustomStringConvertible {
    case cannotGetInterfaces
    case noIPAddressFound

    public var description: String {
        switch self {
        case .cannotGetInterfaces:
            return "Failed to get network interfaces"
        case .noIPAddressFound:
            return "No IP address found on any network interface"
        }
    }
}

// MARK: - Logging Description

extension URRobotScriptHandler: CustomStringConvertible {
    /// String description for logging and debugging.
    public var description: String {
        "URRobotScriptHandler(connectionState: \(connectionState))"
    }
}

import Foundation
#if canImport(Network)
import Network
#endif

/// Network utilities for testing socket connections
public struct NetworkUtilities {

    // MARK: - Port Availability

    /// Checks if a port is available for binding
    /// - Parameter port: The port number to check
    /// - Returns: True if port is available, false if in use
    public static func isPortAvailable(_ port: Int) -> Bool {
        let socketFD = socket(AF_INET, SOCK_STREAM, 0)
        guard socketFD != -1 else { return false }
        defer { close(socketFD) }

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(port).bigEndian
        addr.sin_addr.s_addr = INADDR_ANY

        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(socketFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        return result == 0
    }

    /// Waits for a port to become available (listening)
    /// - Parameters:
    ///   - port: The port to check
    ///   - timeout: Maximum time to wait in seconds
    /// - Throws: NetworkError.timeout if port doesn't become available
    public static func waitForPort(_ port: Int, host: String = "localhost", timeout: TimeInterval = 10.0) async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if try await canConnect(to: host, port: port) {
                return
            }
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }

        throw NetworkError.timeout(port: port, timeout: timeout)
    }

    /// Checks if we can connect to a specific host and port
    /// - Parameters:
    ///   - host: The host to connect to
    ///   - port: The port to connect to
    /// - Returns: True if connection succeeds
    private static func canConnect(to host: String, port: Int) async throws -> Bool {
        let socketFD = socket(AF_INET, SOCK_STREAM, 0)
        guard socketFD != -1 else { return false }
        defer { close(socketFD) }

        // Set non-blocking
        var flags = fcntl(socketFD, F_GETFL, 0)
        flags |= O_NONBLOCK
        fcntl(socketFD, F_SETFL, flags)

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(port).bigEndian

        // Convert host to address
        if let hostent = gethostbyname(host) {
            addr.sin_addr = hostent.pointee.h_addr_list[0]!.withMemoryRebound(to: in_addr.self, capacity: 1) { $0.pointee }
        } else {
            return false
        }

        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(socketFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        // Non-blocking connect returns -1 with EINPROGRESS if connecting
        if result == 0 {
            return true
        }

        // Check if connection is in progress
        let error = errno
        if error == EINPROGRESS {
            // Wait a bit for connection to complete
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

            var err: Int32 = 0
            var len = socklen_t(MemoryLayout<Int32>.size)
            getsockopt(socketFD, SOL_SOCKET, SO_ERROR, &err, &len)

            return err == 0
        }

        return false
    }

    // MARK: - Docker IP Detection

    /// Gets the IP address to use for connecting to Docker container from host
    /// On macOS, this is typically "localhost" or "127.0.0.1"
    /// - Returns: The Docker host IP
    public static func getDockerHostIP() -> String {
        #if os(macOS)
        return "localhost"
        #elseif os(Linux)
        // On Linux, Docker bridge network
        return "172.17.0.1"
        #else
        return "localhost"
        #endif
    }
}

// MARK: - Errors

public enum NetworkError: Error, CustomStringConvertible {
    case timeout(port: Int, timeout: TimeInterval)
    case connectionFailed

    public var description: String {
        switch self {
        case .timeout(let port, let timeout):
            return "Timeout waiting for port \(port) after \(timeout) seconds"
        case .connectionFailed:
            return "Connection failed"
        }
    }
}

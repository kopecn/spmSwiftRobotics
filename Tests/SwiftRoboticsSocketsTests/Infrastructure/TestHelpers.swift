import Foundation
import OpenCombine
import SocketCommon
import Testing

@testable import SwiftRoboticsSockets

/// Test helper utilities for async operations and assertions
public struct TestHelpers {

    // MARK: - Connection Waiting

    /// Waits for a client socket handler to establish connection
    /// - Parameters:
    ///   - handler: Handler with connectionState publisher (Dashboard or URScript)
    ///   - timeout: Maximum time to wait
    /// - Throws: TestError.timeout if connection not established
    public static func waitForConnection(
        _ handler: URRobotDashboardHandler,
        timeout: TimeInterval = TestConfiguration.connectionTimeout
    ) async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if case .connected = handler.connectionState {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        }

        throw TestError.timeout(operation: "dashboard connection", timeout: timeout)
    }

    /// Waits for URScript handler to connect
    public static func waitForConnection(
        _ handler: URRobotScriptHandler,
        timeout: TimeInterval = TestConfiguration.connectionTimeout
    ) async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if case .connected = handler.connectionState {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        }

        throw TestError.timeout(operation: "urscript connection", timeout: timeout)
    }

    /// Waits for a server socket handler to have active connections
    /// - Parameters:
    ///   - handler: Command handler
    ///   - expectedCount: Expected number of connections (default: 1)
    ///   - timeout: Maximum time to wait
    /// - Throws: TestError.timeout if server not active
    public static func waitForServerActive(
        _ handler: URRobotCommandHandler,
        expectedCount: Int = 1,
        timeout: TimeInterval = TestConfiguration.connectionTimeout
    ) async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if case .activeConnections = handler.connectionState {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        }

        throw TestError.timeout(operation: "command server active", timeout: timeout)
    }

    /// Waits for streaming server to have active connections
    public static func waitForServerActive(
        _ handler: URRobotStreamHandler,
        expectedCount: Int = 1,
        timeout: TimeInterval = TestConfiguration.connectionTimeout
    ) async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if case .activeConnections = handler.connectionState {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        }

        throw TestError.timeout(operation: "streaming server active", timeout: timeout)
    }

    // MARK: - Response Waiting

    /// Waits for a response from a handler by polling a response property
    /// - Parameters:
    ///   - timeout: Maximum time to wait
    ///   - condition: Closure that returns true when desired response is received
    /// - Throws: TestError.timeout if response not received
    public static func waitForResponse(
        timeout: TimeInterval = TestConfiguration.commandTimeout,
        condition: @escaping () -> Bool
    ) async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if condition() {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        }

        throw TestError.timeout(operation: "response", timeout: timeout)
    }

    // MARK: - Streaming Helpers

    /// Waits for streaming to become active
    /// - Parameters:
    ///   - handler: The streaming handler
    ///   - timeout: Maximum time to wait
    /// - Throws: TestError.timeout if streaming doesn't start
    public static func waitForStreamingActive(
        _ handler: URRobotStreamHandler,
        timeout: TimeInterval = TestConfiguration.streamingTimeout
    ) async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if handler.hasMoreData {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        }

        throw TestError.timeout(operation: "streaming activation", timeout: timeout)
    }

    /// Waits for streaming to complete
    /// - Parameters:
    ///   - handler: The streaming handler
    ///   - timeout: Maximum time to wait
    /// - Throws: TestError.timeout if streaming doesn't complete
    public static func waitForStreamingComplete(
        _ handler: URRobotStreamHandler,
        timeout: TimeInterval = TestConfiguration.streamingTimeout
    ) async throws {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if !handler.hasMoreData && handler.streamingProgress >= 1.0 {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        }

        throw TestError.timeout(operation: "streaming completion", timeout: timeout)
    }

    // MARK: - Delay Helper

    /// Simple async delay helper
    /// - Parameter seconds: Number of seconds to delay
    public static func delay(_ seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

// MARK: - Test Errors

public enum TestError: Error, CustomStringConvertible {
    case timeout(operation: String, timeout: TimeInterval)
    case unexpectedResponse(expected: String, received: String)
    case connectionFailed(reason: String)
    case assertionFailed(message: String)

    public var description: String {
        switch self {
        case .timeout(let operation, let timeout):
            return "Timeout waiting for \(operation) after \(timeout) seconds"
        case .unexpectedResponse(let expected, let received):
            return "Expected response '\(expected)' but received '\(received)'"
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .assertionFailed(let message):
            return "Assertion failed: \(message)"
        }
    }
}

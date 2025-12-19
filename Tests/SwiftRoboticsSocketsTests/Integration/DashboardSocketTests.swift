import Foundation
import OpenCombine
import SocketCommon
import Testing

@testable import SwiftRoboticsSockets

/// Test suite for Dashboard Socket (Port 29999)
/// Tests connection and dashboard commands
@Suite("Dashboard Socket Tests - Scenario 1", .serialized, .disabled(if: URSimulatorAvailability.skipCondition))
struct DashboardSocketTests {

    // MARK: - Test: Connection

    @Test("Dashboard socket connects successfully")
    func testDashboardConnection() async throws {
        print("\n=== Testing Dashboard Connection ===")
        print("Connecting to \(TestConfiguration.robotIP):\(TestConfiguration.dashboardPort)")

        let handler = URRobotDashboardHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.dashboardPort
        )

        // Initially disconnected
        #expect(handler.connectionState == SocketClientConnectionState.disconnected)

        // Connect
        handler.toggleConnection()

        // Wait for connection
        try await TestHelpers.waitForConnection(handler, timeout: TestConfiguration.connectionTimeout)

        print("✓ Successfully connected to dashboard")
        #expect(handler.connectionState == SocketClientConnectionState.connected)

        // Disconnect
        handler.toggleConnection()

        try await TestHelpers.delay(1.0)
        print("✓ Successfully disconnected")
    }

    // MARK: - Test: Robot Mode Query

    @Test("Dashboard robotMode command returns valid response")
    func testRobotModeCommand() async throws {
        print("\n=== Testing Robot Mode Command ===")

        let handler = URRobotDashboardHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.dashboardPort
        )

        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Connected, waiting for welcome message...")

        // Wait for welcome message to arrive
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse.contains("Connected")
        }

        print("  Received: \(handler.lastDashResponse)")
        let welcomeMessage = handler.lastDashResponse

        print("  Querying robot mode...")

        // Send robotMode command
        handler.robotMode()

        // Wait for response to change from welcome message
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse != welcomeMessage && !handler.lastDashResponse.isEmpty
        }

        print("Robot Mode Response: \(handler.lastDashResponse)")
        #expect(!handler.lastDashResponse.isEmpty, "Should receive robot mode response")

        // Response should contain "Robotmode" or similar
        // URSim typically responds with: "Robotmode: NO_CONTROLLER" or "Robotmode: RUNNING"
        #expect(
            handler.lastDashResponse.contains("Robotmode") || handler.lastDashResponse.contains("NO_CONTROLLER")
                || handler.lastDashResponse.contains("RUNNING"),
            "Response should contain robot mode information"
        )

        handler.toggleConnection()
        print("✓ Robot mode test complete")
    }

    // MARK: - Test: Power On Command

    @Test("Dashboard powerOn command executes")
    func testPowerOnCommand() async throws {
        print("\n=== Testing Power On Command ===")

        let handler = URRobotDashboardHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.dashboardPort
        )

        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Connected, waiting for welcome message...")

        // Wait for welcome message to arrive
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse.contains("Connected")
        }

        print("  Received: \(handler.lastDashResponse)")
        let welcomeMessage = handler.lastDashResponse

        print("  Sending power on command...")

        // Send powerOn command
        handler.powerOn()

        // Wait for response to change from welcome message
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse != welcomeMessage && !handler.lastDashResponse.isEmpty
        }

        print("Power On Response: \(handler.lastDashResponse)")
        #expect(!handler.lastDashResponse.isEmpty, "Should receive power on response")

        // Response typically: "Powering on" or similar
        #expect(
            handler.lastDashResponse.contains("Powering") || handler.lastDashResponse.contains("power")
                || handler.lastDashResponse.contains("Power"),
            "Response should acknowledge power command"
        )

        handler.toggleConnection()
        print("✓ Power on test complete")
    }

    // MARK: - Test: Brake Release

    @Test("Dashboard brakeRelease command executes")
    func testBrakeReleaseCommand() async throws {
        print("\n=== Testing Brake Release Command ===")

        let handler = URRobotDashboardHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.dashboardPort
        )

        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Connected, waiting for welcome message...")

        // Wait for welcome message
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse.contains("Connected")
        }

        let welcomeMessage = handler.lastDashResponse
        print("  Sending brake release command...")

        // Send brakeRelease command
        handler.brakeRelease()

        // Wait for response to change from welcome message
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse != welcomeMessage && !handler.lastDashResponse.isEmpty
        }

        print("Brake Release Response: \(handler.lastDashResponse)")
        #expect(!handler.lastDashResponse.isEmpty, "Should receive brake release response")

        handler.toggleConnection()
        print("✓ Brake release test complete")
    }

    // MARK: - Test: Stop Command

    @Test("Dashboard stop command executes")
    func testStopCommand() async throws {
        print("\n=== Testing Stop Command ===")

        let handler = URRobotDashboardHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.dashboardPort
        )

        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Connected, waiting for welcome message...")

        // Wait for welcome message
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse.contains("Connected")
        }

        let welcomeMessage = handler.lastDashResponse
        print("  Sending stop command...")

        // Send stop command
        handler.stop()

        // Wait for response to change from welcome message
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse != welcomeMessage && !handler.lastDashResponse.isEmpty
        }

        print("Stop Response: \(handler.lastDashResponse)")
        #expect(!handler.lastDashResponse.isEmpty, "Should receive stop response")

        handler.toggleConnection()
        print("✓ Stop test complete")
    }

    // MARK: - Test: Sequential Commands

    @Test("Dashboard handles sequential commands")
    func testSequentialCommands() async throws {
        print("\n=== Testing Sequential Commands ===")

        let handler = URRobotDashboardHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.dashboardPort
        )

        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Connected, waiting for welcome message...")

        // Wait for welcome message
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse.contains("Connected")
        }

        print("  Received: \(handler.lastDashResponse)")
        print("  Sending sequential commands...")

        // Command 1: Robot Mode
        handler.robotMode()
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse.contains("Robotmode") || handler.lastDashResponse.contains("NO_CONTROLLER")
                || handler.lastDashResponse.contains("RUNNING")
        }
        let response1 = handler.lastDashResponse
        print("  Command 1 Response: \(response1)")

        try await TestHelpers.delay(0.5)

        // Command 2: Is Program Saved
        handler.isProgramSaved()
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse != response1
        }
        let response2 = handler.lastDashResponse
        print("  Command 2 Response: \(response2)")

        try await TestHelpers.delay(0.5)

        // Command 3: Safety Status
        handler.safetyStatus()
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            handler.lastDashResponse != response2
        }
        let response3 = handler.lastDashResponse
        print("  Command 3 Response: \(response3)")

        #expect(response1 != response2, "Sequential responses should differ")
        #expect(response2 != response3, "Sequential responses should differ")

        handler.toggleConnection()
        print("✓ Sequential commands test complete")
    }

    // MARK: - Test: Connection State Transitions

    @Test("Dashboard connection state transitions correctly")
    func testConnectionStateTransitions() async throws {
        print("\n=== Testing Connection State Transitions ===")

        let handler = URRobotDashboardHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.dashboardPort
        )

        var stateTransitions: [SocketClientConnectionState] = []
        var cancellable: AnyCancellable?

        // Observe state transitions
        cancellable = handler.$connectionState.sink { state in
            stateTransitions.append(state)
            print("  State transition: \(state)")
        }

        // Initial state
        #expect(handler.connectionState == SocketClientConnectionState.disconnected)

        // Connect
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        #expect(handler.connectionState == SocketClientConnectionState.connected)

        // Disconnect
        handler.toggleConnection()

        try await TestHelpers.delay(1.0)

        // Verify state transitions
        #expect(stateTransitions.count >= 2, "Should have multiple state transitions")
        #expect(stateTransitions.first == .disconnected, "Should start disconnected")
        #expect(
            stateTransitions.contains {
                if case .connected = $0 { return true }
                return false
            },
            "Should transition to connected"
        )

        cancellable?.cancel()
        print("✓ State transitions test complete")
    }
}

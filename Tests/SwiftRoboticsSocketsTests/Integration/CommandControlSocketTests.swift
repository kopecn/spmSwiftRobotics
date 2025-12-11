import Foundation
import OpenCombine
import SocketCommon
import Testing

@testable import SwiftRoboticAssets
@testable import SwiftRoboticsSockets

/// Test suite for Command/Control Socket (Port 50001)
/// Tests command server and robot callback communication
@Suite("Command/Control Socket Tests - Scenario 3")
struct CommandControlSocketTests {

    // MARK: - Test: Server Startup

    @Test("Command server starts on port 50001")
    func testCommandServerStartup() async throws {
        print("\n=== Testing Command Server Startup ===")

        let handler = URRobotCommandHandler(port: TestConfiguration.commandPort)

        // Initially off
        #expect(handler.connectionState == SocketServerListeningState.off)

        // Start server
        handler.toggleConnection()

        // Wait for listening state
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            handler.connectionState == SocketServerListeningState.listening
        }

        print("✓ Command server listening on port \(TestConfiguration.commandPort)")
        #expect(handler.connectionState == SocketServerListeningState.listening)

        // Stop server
        handler.toggleConnection()

        try await TestHelpers.delay(1.0)
        print("✓ Server stopped")
    }

    // MARK: - Test: Complete Callback Flow

    @Test("Complete flow: URScript → Command callback → Commands")
    func testCompleteCommandFlow() async throws {
        print("\n=== Testing Complete Command/Control Flow ===")
        print("This test requires URScript to be loaded and callback established")

        // Step 1: Start command server
        let commandHandler = URRobotCommandHandler(port: TestConfiguration.commandPort)
        commandHandler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            commandHandler.connectionState == SocketServerListeningState.listening
        }

        print("✓ Command server listening")

        // Step 2: Send URScript to establish callback
        let scriptHandler = URRobotScriptHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.urScriptPort
        )
        scriptHandler.callbackIPAddress = TestConfiguration.hostCallbackIP

        scriptHandler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case .connected = scriptHandler.connectionState {
                return true
            }
            return false
        }

        print("✓ Connected to URScript port")

        // Prepare and send script
        let preparedScript = try URScriptTemplateManager.prepareScriptWithTestConfig()
        let tempDir = FileManager.default.temporaryDirectory
        let scriptPath = tempDir.appendingPathComponent("test_cmd_flow.script")
        try preparedScript.write(to: scriptPath, atomically: true, encoding: .utf8)

        print("✓ Sending URScript to robot...")
        scriptHandler.loadAndPushURScript(fromPath: scriptPath.path)

        // Step 3: Wait for robot to connect back to command server
        print("  Waiting for robot callback connection...")
        try await TestHelpers.waitForResponse(timeout: 15.0) {
            if case SocketServerListeningState.activeConnections = commandHandler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected to command server!")
        print("  Server state: \(commandHandler.connectionState)")

        // Step 4: Send commands and verify responses

        // Command: initRobot
        print("\n  Sending: initRobot")
        commandHandler.initRobot()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            !commandHandler.lastResponse.isEmpty
        }

        print("  Response: \(commandHandler.lastResponse)")
        #expect(!commandHandler.lastResponse.isEmpty, "Should receive response for initRobot")

        try await TestHelpers.delay(1.0)

        // Command: status
        print("\n  Sending: status")
        commandHandler.status()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            commandHandler.lastResponse.contains("res") || commandHandler.lastResponse.contains("ack")
        }

        print("  Response: \(commandHandler.lastResponse)")
        #expect(!commandHandler.lastResponse.isEmpty, "Should receive response for status")

        try await TestHelpers.delay(1.0)

        // Command: home
        print("\n  Sending: home")
        commandHandler.home()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.movementTimeout) {
            commandHandler.lastResponse.contains("ack") || commandHandler.lastResponse.contains("res")
        }

        print("  Response: \(commandHandler.lastResponse)")
        #expect(!commandHandler.lastResponse.isEmpty, "Should receive response for home")

        print("\n✓ Complete command flow test successful!")

        // Cleanup
        try? FileManager.default.removeItem(at: scriptPath)
        scriptHandler.toggleConnection()
        commandHandler.toggleConnection()
    }

    // MARK: - Test: Init Command

    @Test("initRobot command sends and receives ack")
    func testInitRobotCommand() async throws {
        print("\n=== Testing initRobot Command ===")
        print("NOTE: This test requires active robot connection via URScript callback")

        let handler = URRobotCommandHandler(port: TestConfiguration.commandPort)
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            handler.connectionState == SocketServerListeningState.listening
        }

        print("✓ Command server listening")
        print("⚠️  Ensure URScript callback is established before running this test")

        // Wait for active connection
        print("  Waiting for robot connection...")
        try await TestHelpers.waitForResponse(timeout: 20.0) {
            if case SocketServerListeningState.activeConnections = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected")

        // Send initRobot
        handler.initRobot()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            !handler.lastResponse.isEmpty
        }

        print("  Response: \(handler.lastResponse)")
        #expect(!handler.lastResponse.isEmpty, "Should receive acknowledgment")

        handler.toggleConnection()
        print("✓ initRobot test complete")
    }

    // MARK: - Test: Home Command

    @Test("home command executes successfully")
    func testHomeCommand() async throws {
        print("\n=== Testing home Command ===")
        print("NOTE: This test requires active robot connection via URScript callback")

        let handler = URRobotCommandHandler(port: TestConfiguration.commandPort)
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            handler.connectionState == SocketServerListeningState.listening
        }

        // Wait for active connection
        try await TestHelpers.waitForResponse(timeout: 20.0) {
            if case SocketServerListeningState.activeConnections = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected")

        // Send home
        print("  Sending home command...")
        handler.home()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.movementTimeout) {
            !handler.lastResponse.isEmpty
        }

        print("  Response: \(handler.lastResponse)")
        #expect(!handler.lastResponse.isEmpty, "Should receive acknowledgment for home")

        handler.toggleConnection()
        print("✓ home command test complete")
    }

    // MARK: - Test: Status Command

    @Test("status command returns robot status")
    func testStatusCommand() async throws {
        print("\n=== Testing status Command ===")
        print("NOTE: This test requires active robot connection via URScript callback")

        let handler = URRobotCommandHandler(port: TestConfiguration.commandPort)
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            handler.connectionState == SocketServerListeningState.listening
        }

        // Wait for active connection
        try await TestHelpers.waitForResponse(timeout: 20.0) {
            if case SocketServerListeningState.activeConnections = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected")

        // Send status
        handler.status()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            !handler.lastResponse.isEmpty
        }

        print("  Response: \(handler.lastResponse)")
        #expect(!handler.lastResponse.isEmpty, "Should receive status response")

        handler.toggleConnection()
        print("✓ status command test complete")
    }

    // MARK: - Test: Version Command

    @Test("ver command returns version info")
    func testVersionCommand() async throws {
        print("\n=== Testing ver Command ===")
        print("NOTE: This test requires active robot connection via URScript callback")

        let handler = URRobotCommandHandler(port: TestConfiguration.commandPort)
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            handler.connectionState == SocketServerListeningState.listening
        }

        // Wait for active connection
        try await TestHelpers.waitForResponse(timeout: 20.0) {
            if case SocketServerListeningState.activeConnections = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected")

        // Send ver
        handler.ver()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            !handler.lastResponse.isEmpty
        }

        print("  Response: \(handler.lastResponse)")
        #expect(!handler.lastResponse.isEmpty, "Should receive version response")

        handler.toggleConnection()
        print("✓ ver command test complete")
    }

    // MARK: - Test: Current Pose Command

    @Test("currentpose command returns robot pose")
    func testCurrentPoseCommand() async throws {
        print("\n=== Testing currentpose Command ===")
        print("NOTE: This test requires active robot connection via URScript callback")

        let handler = URRobotCommandHandler(port: TestConfiguration.commandPort)
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            handler.connectionState == SocketServerListeningState.listening
        }

        // Wait for active connection
        try await TestHelpers.waitForResponse(timeout: 20.0) {
            if case SocketServerListeningState.activeConnections = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected")

        // Send currentpose
        handler.currentpose()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            !handler.lastResponse.isEmpty
        }

        print("  Response: \(handler.lastResponse)")
        #expect(!handler.lastResponse.isEmpty, "Should receive pose response")

        handler.toggleConnection()
        print("✓ currentpose command test complete")
    }

    // MARK: - Test: Sequential Commands

    @Test("Sequential commands execute in order")
    func testSequentialCommands() async throws {
        print("\n=== Testing Sequential Commands ===")
        print("NOTE: This test requires active robot connection via URScript callback")

        let handler = URRobotCommandHandler(port: TestConfiguration.commandPort)
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            handler.connectionState == SocketServerListeningState.listening
        }

        // Wait for active connection
        try await TestHelpers.waitForResponse(timeout: 20.0) {
            if case SocketServerListeningState.activeConnections = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected")

        let commands = ["initRobot", "status", "ver", "currentpose"]

        for (index, cmdName) in commands.enumerated() {
            print("\n  Command \(index + 1)/\(commands.count): \(cmdName)")

            switch cmdName {
            case "initRobot": handler.initRobot()
            case "status": handler.status()
            case "ver": handler.ver()
            case "currentpose": handler.currentpose()
            default: break
            }

            try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
                !handler.lastResponse.isEmpty
            }

            print("    Response: \(handler.lastResponse)")
            #expect(!handler.lastResponse.isEmpty, "Should receive response for \(cmdName)")

            try await TestHelpers.delay(0.5)
        }

        handler.toggleConnection()
        print("\n✓ Sequential commands test complete")
    }
}

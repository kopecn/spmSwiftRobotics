import Testing
import Foundation
import OpenCombine
@testable import SwiftRoboticsSockets
import SocketCommon
@testable import SwiftRoboticAssets

/// Test suite for URScript Socket (Port 30001)
/// Tests urScript loading and callback establishment
@Suite("URScript Socket Tests - Scenario 2")
struct URScriptSocketTests {
    
    // MARK: - Test: Connection

    @Test("URScript socket connects successfully")
    func testURScriptConnection() async throws {
        print("\n=== Testing URScript Connection ===")
        print("Connecting to \(TestConfiguration.robotIP):\(TestConfiguration.urScriptPort)")

        let handler = URRobotScriptHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.urScriptPort
        )

        // Initially disconnected
        #expect(handler.connectionState == SocketClientConnectionState.disconnected)

        // Connect
        handler.toggleConnection()

        // Wait for connection
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Successfully connected to URScript port")
        #expect(handler.connectionState == SocketClientConnectionState.connected)

        // Disconnect
        handler.toggleConnection()

        try await TestHelpers.delay(1.0)
        print("✓ Successfully disconnected")
    }

    // MARK: - Test: Template Loading

    @Test("URScript template loads with placeholder")
    func testTemplateLoading() async throws {
        print("\n=== Testing URScript Template Loading ===")

        // Load template
        let template = try URScriptTemplateManager.loadTemplate()

        print("✓ Template loaded, size: \(template.count) bytes")

        // Verify placeholder exists
        #expect(
            template.contains(URScriptTemplateManager.hostIPPlaceholder),
            "Template should contain placeholder: \(URScriptTemplateManager.hostIPPlaceholder)"
        )

        // Verify template is not prepared (still has placeholder)
        #expect(
            !URScriptTemplateManager.isScriptPrepared(template),
            "Template should not be prepared (should have placeholder)"
        )

        print("✓ Template contains placeholder: \(URScriptTemplateManager.hostIPPlaceholder)")
    }

    // MARK: - Test: IP Replacement

    @Test("URScript host IP replacement works correctly")
    func testHostIPReplacement() async throws {
        print("\n=== Testing Host IP Replacement ===")

        // Load template
        let template = try URScriptTemplateManager.loadTemplate()

        // Test replacement with a known IP
        let testIP = "192.168.1.100"
        let prepared = URScriptTemplateManager.replaceHostIP(in: template, with: testIP)

        print("✓ IP replacement complete")

        // Verify placeholder is gone
        #expect(
            !prepared.contains(URScriptTemplateManager.hostIPPlaceholder),
            "Prepared script should not contain placeholder"
        )

        // Verify test IP is present
        #expect(
            prepared.contains(testIP),
            "Prepared script should contain the test IP: \(testIP)"
        )

        // Verify script is prepared
        #expect(
            URScriptTemplateManager.isScriptPrepared(prepared),
            "Script should be marked as prepared"
        )

        print("✓ Placeholder replaced with: \(testIP)")
    }

    // MARK: - Test: Auto IP Detection

    @Test("URScript auto-detects host IP")
    func testAutoIPDetection() async throws {
        print("\n=== Testing Auto IP Detection ===")

        // Auto-detect IP
        let hostIP = try URScriptTemplateManager.getHostIPAddress()

        print("✓ Auto-detected host IP: \(hostIP)")

        // Verify it's a valid IP format (basic check)
        #expect(
            hostIP.contains("."),
            "IP address should contain dots"
        )

        #expect(
            !hostIP.isEmpty,
            "IP address should not be empty"
        )

        // Verify it's not a loopback address
        #expect(
            !hostIP.hasPrefix("127."),
            "IP address should not be loopback"
        )

        print("✓ Valid IP address detected")
    }

    // MARK: - Test: Prepare Script for Test

    @Test("URScript prepares complete script for testing")
    func testPrepareScriptForTest() async throws {
        print("\n=== Testing Prepare Script for Test ===")

        // Prepare with auto-detected IP
        let script1 = try URScriptTemplateManager.prepareScriptForTest()

        print("✓ Script prepared with auto-detected IP")
        #expect(URScriptTemplateManager.isScriptPrepared(script1), "Script should be prepared")

        // Prepare with manual IP
        let manualIP = "10.0.0.50"
        let script2 = try URScriptTemplateManager.prepareScriptForTest(hostIP: manualIP)

        print("✓ Script prepared with manual IP: \(manualIP)")
        #expect(script2.contains(manualIP), "Script should contain manual IP")
        #expect(URScriptTemplateManager.isScriptPrepared(script2), "Script should be prepared")

        // Prepare with test config
        let script3 = try URScriptTemplateManager.prepareScriptWithTestConfig()

        print("✓ Script prepared with test config IP: \(TestConfiguration.hostCallbackIP)")
        #expect(URScriptTemplateManager.isScriptPrepared(script3), "Script should be prepared")
    }

    // MARK: - Test: Load and Send URScript

    @Test("URScript loads and sends to robot")
    func testLoadAndSendURScript() async throws {
        print("\n=== Testing Load and Send URScript ===")

        let handler = URRobotScriptHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.urScriptPort
        )

        // Connect
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Connected to URScript port")

        // Prepare script with test configuration IP
        let preparedScript = try URScriptTemplateManager.prepareScriptWithTestConfig()

        print("✓ Script prepared, size: \(preparedScript.count) bytes")
        print("  Host callback IP: \(TestConfiguration.hostCallbackIP)")

        // Save prepared script to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let scriptPath = tempDir.appendingPathComponent("test_urScript.script")
        try preparedScript.write(to: scriptPath, atomically: true, encoding: .utf8)

        print("✓ Saved prepared script to: \(scriptPath.path)")

        // Load and send the script
        // Note: This will establish callbacks on ports 50001 and 50002
        handler.loadAndPushURScript(fromPath: scriptPath.path)

        // Give the robot time to receive and process the script
        try await TestHelpers.delay(3.0)

        print("✓ URScript sent to robot")
        print("  Robot should now be establishing callbacks on ports 50001 and 50002")

        // Clean up
        try? FileManager.default.removeItem(at: scriptPath)

        handler.toggleConnection()
        print("✓ URScript load and send test complete")
    }

    // MARK: - Test: Script Content Validation

    @Test("URScript contains required components")
    func testScriptContentValidation() async throws {
        print("\n=== Testing URScript Content Validation ===")

        let script = try URScriptTemplateManager.prepareScriptForTest()

        // Check for key components
        let requiredComponents = [
            "def body():",
            "command_port = 50001",
            "streaming_port = 50002",
            "socket_cmd",
            "socket_stream",
            "initRobot",
            "home",
            "status",
            "startstreaming",
            "stopstreaming"
        ]

        for component in requiredComponents {
            #expect(
                script.contains(component),
                "Script should contain: \(component)"
            )
            print("✓ Found: \(component)")
        }

        print("✓ All required components present in script")
    }

    // MARK: - Test: Multiple Script Sends

    @Test("URScript can be sent multiple times")
    func testMultipleScriptSends() async throws {
        print("\n=== Testing Multiple Script Sends ===")

        let handler = URRobotScriptHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.urScriptPort
        )

        // Connect
        handler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            if case SocketClientConnectionState.connected = handler.connectionState {
                return true
            }
            return false
        }

        print("✓ Connected to URScript port")

        let preparedScript = try URScriptTemplateManager.prepareScriptWithTestConfig()
        let tempDir = FileManager.default.temporaryDirectory
        let scriptPath = tempDir.appendingPathComponent("test_urScript_multi.script")
        try preparedScript.write(to: scriptPath, atomically: true, encoding: .utf8)

        // Send first time
        print("  Sending script (1/2)...")
        handler.loadAndPushURScript(fromPath: scriptPath.path)
        try await TestHelpers.delay(2.0)

        // Send second time (should terminate previous and start new)
        print("  Sending script (2/2)...")
        handler.loadAndPushURScript(fromPath: scriptPath.path)
        try await TestHelpers.delay(2.0)

        print("✓ Multiple script sends completed")

        // Clean up
        try? FileManager.default.removeItem(at: scriptPath)

        handler.toggleConnection()
        print("✓ Multiple script sends test complete")
    }
}

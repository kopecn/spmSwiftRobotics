import Foundation
import OpenCombine
import SocketCommon
import Testing

@testable import SwiftRoboticAssets
@testable import SwiftRoboticsSockets

/// Test suite for Streaming Socket (Port 50002)
/// Tests waveform loading and streaming to robot
@Suite("Streaming Socket Tests - Scenario 4", .serialized)
struct StreamingSocketTests {

    // MARK: - Test: Server Startup

    @Test("Streaming server starts on port 50002")
    func testStreamingServerStartup() async throws {
        print("\n=== Testing Streaming Server Startup ===")

        let handler = URRobotStreamHandler(port: TestConfiguration.streamingPort)

        // Initially off
        #expect(handler.connectionState == SocketServerListeningState.off)

        // Start server
        handler.toggleConnection()

        // Wait for listening state
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            handler.connectionState == SocketServerListeningState.listening
        }

        print("✓ Streaming server listening on port \(TestConfiguration.streamingPort)")
        #expect(handler.connectionState == SocketServerListeningState.listening)

        // Stop server
        handler.toggleConnection()

        try await TestHelpers.delay(1.0)
        print("✓ Server stopped")
    }

    // MARK: - Test: Waveform Loading

    @Test("Waveform loads from streamRotateBase.json")
    func testWaveformLoading() async throws {
        print("\n=== Testing Waveform Loading ===")

        let handler = URRobotStreamHandler(port: TestConfiguration.streamingPort)

        // Load waveform
        try handler.loadWaveformWithError(
            fromResource: TestConfiguration.defaultWaveformResource,
            posesPerBatch: TestConfiguration.defaultPosesPerBatch
        )

        print("✓ Waveform loaded: \(TestConfiguration.defaultWaveformResource)")

        // Verify waveform is loaded
        #expect(handler.currentlyLoadedWaveform != nil, "Waveform should be loaded")

        // Check if has data
        #expect(handler.hasMoreData, "Waveform should have data to stream")

        // Check streaming stats
        guard let stats = handler.streamingStats else {
            throw TestError.assertionFailed(message: "No streaming stats available")
        }
        print("  Total poses: \(stats.total)")
        print("  Current index: \(stats.current)")
        print("  Remaining: \(stats.remaining)")

        #expect(stats.total > 0, "Should have poses to stream")
        #expect(stats.remaining > 0, "Should have remaining poses")

        print("✓ Waveform loading test complete")
    }

    // MARK: - Test: Batch Dequeuing

    @Test("Batch dequeuing returns correct format")
    func testBatchDequeuing() async throws {
        print("\n=== Testing Batch Dequeuing ===")

        let handler = URRobotStreamHandler(port: TestConfiguration.streamingPort)

        // Load waveform
        try handler.loadWaveformWithError(
            fromResource: TestConfiguration.defaultWaveformResource,
            posesPerBatch: TestConfiguration.defaultPosesPerBatch
        )

        // Dequeue first batch
        guard let batch = handler.dequeueNextBatch() else {
            throw TestError.assertionFailed(message: "Failed to dequeue batch")
        }

        print("✓ First batch dequeued")
        print("  Batch format: \(batch.prefix(50))...")

        // Verify format: should start with "(" and end with ")"
        #expect(batch.hasPrefix("("), "Batch should start with '('")
        #expect(batch.hasSuffix(")"), "Batch should end with ')'")

        // Count values (should be 6 joints * posesPerBatch)
        let expectedValues = 6 * TestConfiguration.defaultPosesPerBatch
        let components =
            batch
            .trimmingCharacters(in: CharacterSet(charactersIn: "() "))
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
            .filter { !$0.isEmpty }

        print("  Expected values: \(expectedValues)")
        print("  Actual values: \(components.count)")

        #expect(
            components.count == expectedValues,
            "Batch should contain \(expectedValues) values"
        )

        // Verify all values are numbers
        for component in components {
            #expect(Float(component) != nil, "All values should be valid numbers")
        }

        print("✓ Batch format validation complete")
    }

    // MARK: - Test: Streaming Progress

    @Test("Streaming progress tracking works")
    func testStreamingProgress() async throws {
        print("\n=== Testing Streaming Progress ===")

        let handler = URRobotStreamHandler(port: TestConfiguration.streamingPort)

        // Load waveform
        try handler.loadWaveformWithError(
            fromResource: TestConfiguration.defaultWaveformResource,
            posesPerBatch: TestConfiguration.defaultPosesPerBatch
        )

        print("✓ Waveform loaded")

        // Initial progress
        let initialProgress = handler.streamingProgress
        print("  Initial progress: \(initialProgress)")
        #expect(initialProgress == 0.0, "Initial progress should be 0")

        // Dequeue some batches
        var batchCount = 0
        while handler.hasMoreData && batchCount < 3 {
            _ = handler.dequeueNextBatch()
            batchCount += 1

            let currentProgress = handler.streamingProgress
            print("  Progress after batch \(batchCount): \(currentProgress)")
            #expect(currentProgress > 0.0, "Progress should increase")
        }

        print("✓ Progress tracking verified after \(batchCount) batches")

        // Dequeue all remaining batches
        while handler.hasMoreData {
            _ = handler.dequeueNextBatch()
        }

        let finalProgress = handler.streamingProgress
        print("  Final progress: \(finalProgress)")
        #expect(finalProgress == 1.0, "Final progress should be 1.0")

        print("✓ Streaming progress test complete")
    }

    // MARK: - Test: Complete Streaming Flow

    @Test("Complete streaming flow with robot callback", .disabled(if: URSimulatorAvailability.skipCondition))
    func testCompleteStreamingFlow() async throws {
        print("\n=== Testing Complete Streaming Flow ===")
        print("This test requires URScript callback and command connection")

        // Step 1: Start command and streaming servers
        let commandHandler = URRobotCommandHandler(port: TestConfiguration.commandPort)
        let streamHandler = URRobotStreamHandler(port: TestConfiguration.streamingPort)

        commandHandler.toggleConnection()
        streamHandler.toggleConnection()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.connectionTimeout) {
            commandHandler.connectionState == SocketServerListeningState.listening
                && streamHandler.connectionState == SocketServerListeningState.listening
        }

        print("✓ Command and streaming servers listening")

        // Step 2: Send URScript to establish callbacks
        let scriptHandler = URRobotScriptHandler(
            ipAddress: TestConfiguration.robotIP,
            port: TestConfiguration.urScriptPort
        )

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
        let scriptPath = tempDir.appendingPathComponent("test_stream_flow.script")
        try preparedScript.write(to: scriptPath, atomically: true, encoding: .utf8)

        print("✓ Sending URScript to robot...")
        scriptHandler.loadAndPushURScript(fromPath: scriptPath.path)

        // Step 3: Wait for robot to connect to command server
        print("  Waiting for command connection...")
        try await TestHelpers.waitForResponse(timeout: 15.0) {
            if case SocketServerListeningState.activeConnections = commandHandler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected to command server")

        // Step 4: Initialize robot
        commandHandler.initRobot()
        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            !commandHandler.lastResponse.isEmpty
        }
        print("✓ Robot initialized")
        try await TestHelpers.delay(1.0)

        // Step 5: Load waveform
        try streamHandler.loadWaveformWithError(
            fromResource: TestConfiguration.defaultWaveformResource,
            posesPerBatch: TestConfiguration.defaultPosesPerBatch
        )

        print("✓ Waveform loaded")
        print("  Total poses: \(streamHandler.streamingStats?.total ?? 0)")

        // Step 6: Start streaming
        print("  Sending startstreaming command...")
        commandHandler.startstreaming()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            commandHandler.lastResponse.contains("ack") || commandHandler.lastResponse.contains("res")
        }

        print("✓ Streaming command acknowledged")

        // Step 7: Wait for streaming connection
        print("  Waiting for streaming connection...")
        try await TestHelpers.waitForResponse(timeout: 10.0) {
            if case SocketServerListeningState.activeConnections = streamHandler.connectionState {
                return true
            }
            return false
        }

        print("✓ Robot connected to streaming server!")

        // Step 8: Monitor streaming progress
        print("\n  Monitoring streaming progress...")
        var lastProgress: Float = 0.0
        var progressChecks: Float = 0

        while streamHandler.hasMoreData && progressChecks < 30 {
            let currentProgress = streamHandler.streamingProgress

            if currentProgress != lastProgress, let stats = streamHandler.streamingStats {
                print(
                    "    Progress: \(String(format: "%.1f%%", currentProgress * 100)) - "
                        + "Batch \(stats.current)/\(stats.total) - " + "Remaining: \(stats.remaining)"
                )
                lastProgress = currentProgress
            }

            try await TestHelpers.delay(0.5)
            progressChecks += 1

            // If no more data, break
            if !streamHandler.hasMoreData {
                break
            }
        }

        print("\n✓ Streaming progress monitored")
        print("  Final progress: \(String(format: "%.1f%%", streamHandler.streamingProgress * 100))")

        // Step 9: Stop streaming
        print("\n  Sending stopstreaming command...")
        commandHandler.stopstreaming()

        try await TestHelpers.waitForResponse(timeout: TestConfiguration.commandTimeout) {
            commandHandler.lastResponse.contains("ack") || commandHandler.lastResponse.contains("res")
        }

        print("✓ Streaming stopped")

        print("\n✓ Complete streaming flow test successful!")

        // Cleanup
        try? FileManager.default.removeItem(at: scriptPath)
        scriptHandler.toggleConnection()
        commandHandler.toggleConnection()
        streamHandler.toggleConnection()
    }

    // MARK: - Test: Waveform Reset

    @Test("Waveform can be reset and restreamed")
    func testWaveformReset() async throws {
        print("\n=== Testing Waveform Reset ===")

        let handler = URRobotStreamHandler(port: TestConfiguration.streamingPort)

        // Load waveform
        try handler.loadWaveformWithError(
            fromResource: TestConfiguration.defaultWaveformResource,
            posesPerBatch: TestConfiguration.defaultPosesPerBatch
        )

        // Dequeue some batches
        var batchCount = 0
        while handler.hasMoreData && batchCount < 3 {
            _ = handler.dequeueNextBatch()
            batchCount += 1
        }

        print("✓ Dequeued \(batchCount) batches")
        print("  Progress: \(handler.streamingProgress)")

        // Get current stats
        guard let statsBeforeReset = handler.streamingStats else {
            throw TestError.assertionFailed(message: "No streaming stats available")
        }
        print("  Stats before reset: current=\(statsBeforeReset.current), remaining=\(statsBeforeReset.remaining)")

        // Reset (reload waveform)
        try handler.loadWaveformWithError(
            fromResource: TestConfiguration.defaultWaveformResource,
            posesPerBatch: TestConfiguration.defaultPosesPerBatch
        )

        print("✓ Waveform reset")

        // Verify reset
        guard let statsAfterReset = handler.streamingStats else {
            throw TestError.assertionFailed(message: "No streaming stats available")
        }
        print("  Stats after reset: current=\(statsAfterReset.current), remaining=\(statsAfterReset.remaining)")

        #expect(statsAfterReset.current == 0, "Current should be reset to 0")
        #expect(statsAfterReset.remaining == statsAfterReset.total, "Remaining should equal total")
        #expect(handler.streamingProgress == 0.0, "Progress should be reset to 0")
        #expect(handler.hasMoreData, "Should have data after reset")

        print("✓ Waveform reset test complete")
    }

    // MARK: - Test: Multiple Waveforms

    @Test("Different waveforms can be loaded")
    func testMultipleWaveforms() async throws {
        print("\n=== Testing Multiple Waveform Loading ===")

        let handler = URRobotStreamHandler(port: TestConfiguration.streamingPort)

        // Load first waveform
        try handler.loadWaveformWithError(
            fromResource: TestConfiguration.defaultWaveformResource,
            posesPerBatch: 5
        )

        guard let stats1 = handler.streamingStats else {
            throw TestError.assertionFailed(message: "No streaming stats available")
        }
        print("✓ First waveform loaded: \(stats1.total) poses")

        // Load with different batch size
        try handler.loadWaveformWithError(
            fromResource: TestConfiguration.defaultWaveformResource,
            posesPerBatch: 10
        )

        guard let stats2 = handler.streamingStats else {
            throw TestError.assertionFailed(message: "No streaming stats available")
        }
        print("✓ Second waveform loaded (different batch): \(stats2.total) poses")

        #expect(stats1.total == stats2.total, "Total poses should be same")
        #expect(handler.hasMoreData, "Should have data")

        print("✓ Multiple waveform loading test complete")
    }
}

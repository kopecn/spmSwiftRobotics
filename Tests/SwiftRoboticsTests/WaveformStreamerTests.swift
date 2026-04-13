import Testing

@testable import SwiftRobotics

// MARK: - Minimal mock waveform

/// Simple mock waveform: N poses, each with 6 fixed joint values equal to the pose index.
private struct MockWaveform: StreamWaveformProtocol {
    let sampleCount: Int

    func joints(at index: Int) -> [Float] {
        let v = Float(index)
        return [v, v, v, v, v, v]
    }
}

// MARK: - WaveformStreamer Tests

@Suite("WaveformStreamer Tests")
struct WaveformStreamerTests {

    // MARK: - Basic dequeue

    @Test("dequeueRadians returns joints converted to radians")
    func testDequeueRadiansConversion() {
        let waveform = MockWaveform(sampleCount: 3)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 1)

        // joints(at:0) returns [0,0,0,0,0,0] → radians = 0
        guard let batch = streamer.dequeueRadians() else {
            Issue.record("Expected non-nil batch for pose 0")
            return
        }
        #expect(batch.count == 6)
        for v in batch {
            #expect(v == 0.0 * .pi / 180.0, "Pose 0 in radians should be 0")
        }

        // joints(at:1) → [1,1,1,1,1,1] degrees → 1 * π/180
        guard let batch2 = streamer.dequeueRadians() else {
            Issue.record("Expected non-nil batch for pose 1")
            return
        }
        let expectedRad = Float(1) * .pi / 180.0
        for v in batch2 {
            #expect(abs(v - expectedRad) < 1e-6)
        }
    }

    @Test("dequeueDegrees returns raw joint values")
    func testDequeueDegreesRawValues() {
        let waveform = MockWaveform(sampleCount: 4)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 2)

        guard let batch = streamer.dequeueDegrees() else {
            Issue.record("Expected non-nil batch")
            return
        }
        // 2 poses × 6 joints = 12 values; pose 0 → all 0.0, pose 1 → all 1.0
        #expect(batch.count == 12)
        for i in 0..<6 { #expect(batch[i] == 0.0) }
        for i in 6..<12 { #expect(batch[i] == 1.0) }
    }

    // MARK: - Batch sizing

    @Test("Batch size is respected")
    func testBatchSize() {
        let waveform = MockWaveform(sampleCount: 10)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 3)

        guard let batch = streamer.dequeueRadians() else {
            Issue.record("First batch should not be nil")
            return
        }
        #expect(batch.count == 3 * 6, "3 poses × 6 joints")
        #expect(streamer.index == 3)
    }

    @Test("Last batch returns only remaining poses")
    func testPartialLastBatch() {
        let waveform = MockWaveform(sampleCount: 5)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 3)

        _ = streamer.dequeueRadians()          // consumes poses 0-2
        guard let last = streamer.dequeueRadians() else {
            Issue.record("Second batch should contain remaining 2 poses")
            return
        }
        #expect(last.count == 2 * 6, "Should return only the 2 remaining poses")
    }

    // MARK: - Boundary conditions

    @Test("Returns nil when no more data")
    func testReturnsNilWhenExhausted() {
        let waveform = MockWaveform(sampleCount: 2)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 2)

        _ = streamer.dequeueRadians()
        let empty = streamer.dequeueRadians()
        #expect(empty == nil, "Should return nil after all poses consumed")
    }

    @Test("hasMore tracks dequeue progress")
    func testHasMoreTracksProgress() {
        let waveform = MockWaveform(sampleCount: 3)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 1)

        #expect(streamer.hasMore)
        _ = streamer.dequeueRadians()
        #expect(streamer.hasMore)
        _ = streamer.dequeueRadians()
        _ = streamer.dequeueRadians()
        #expect(!streamer.hasMore)
    }

    @Test("remaining decrements correctly")
    func testRemainingCount() {
        let waveform = MockWaveform(sampleCount: 6)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 2)

        #expect(streamer.remaining == 6)
        _ = streamer.dequeueRadians()
        #expect(streamer.remaining == 4)
        _ = streamer.dequeueRadians()
        #expect(streamer.remaining == 2)
        _ = streamer.dequeueRadians()
        #expect(streamer.remaining == 0)
    }

    @Test("totalPoses reflects waveform sample count")
    func testTotalPoses() {
        let waveform = MockWaveform(sampleCount: 42)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 5)
        #expect(streamer.totalPoses == 42)
    }

    // MARK: - Peek

    @Test("peekRadians does not advance index")
    func testPeekDoesNotAdvanceIndex() {
        let waveform = MockWaveform(sampleCount: 5)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 2)

        let peeked = streamer.peekRadians()
        let dequeued = streamer.dequeueRadians()

        #expect(peeked == dequeued, "Peek and dequeue should return identical data")
        #expect(streamer.index == 2, "Index should only advance after dequeue, not peek")
    }

    // MARK: - Reset

    @Test("reset returns streamer to beginning")
    func testReset() {
        let waveform = MockWaveform(sampleCount: 4)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 4)

        _ = streamer.dequeueRadians()
        #expect(!streamer.hasMore)

        streamer.reset()
        #expect(streamer.hasMore)
        #expect(streamer.index == 0)
        #expect(streamer.remaining == 4)
    }

    // MARK: - Custom count override

    @Test("dequeueRadians(count:) overrides batch size")
    func testCustomCountOverride() {
        let waveform = MockWaveform(sampleCount: 10)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 5)

        guard let batch = streamer.dequeueRadians(count: 2) else {
            Issue.record("Expected batch")
            return
        }
        #expect(batch.count == 2 * 6)
        #expect(streamer.index == 2)
    }

    @Test("Empty waveform returns nil immediately")
    func testEmptyWaveform() {
        let waveform = MockWaveform(sampleCount: 0)
        let streamer = WaveformStreamer(waveform: waveform, posesPerBatch: 5)
        #expect(!streamer.hasMore)
        #expect(streamer.remaining == 0)
        #expect(streamer.dequeueRadians() == nil)
    }
}

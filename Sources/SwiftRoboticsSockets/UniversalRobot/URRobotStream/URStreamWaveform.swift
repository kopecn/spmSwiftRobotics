import Foundation

/// Represents a robot joint streaming waveform loaded from JSON
public struct URStreamWaveform: Codable {

    /// Metadata about the waveform
    public struct Metadata: Codable {
        /// Name of the waveform
        public let name: String

        /// Description of the waveform
        public let desc: String

        public init(name: String, desc: String) {
            self.name = name
            self.desc = desc
        }
    }

    /// Metadata about this waveform
    public let metadata: Metadata

    /// Joint 1 positions (base rotation) - typically in degrees
    public let j1: [Float]

    /// Joint 2 positions (shoulder) - typically in degrees
    public let j2: [Float]

    /// Joint 3 positions (elbow) - typically in degrees
    public let j3: [Float]

    /// Joint 4 positions (wrist 1) - typically in degrees
    public let j4: [Float]

    /// Joint 5 positions (wrist 2) - typically in degrees
    public let j5: [Float]

    /// Joint 6 positions (wrist 3) - typically in degrees
    public let j6: [Float]

    /// The number of samples in this waveform (based on the longest joint array)
    public var sampleCount: Int {
        max(j1.count, j2.count, j3.count, j4.count, j5.count, j6.count)
    }

    /// Returns all 6 joint positions for a given sample index
    /// - Parameter index: The sample index (0..<sampleCount)
    /// - Returns: Array of 6 joint positions [j1, j2, j3, j4, j5, j6] in degrees
    public func joints(at index: Int) -> [Float] {
        guard index >= 0 && index < sampleCount else {
            return [0, 0, 0, 0, 0, 0]
        }

        return [
            j1[safe: index] ?? j1.last ?? 0.0,
            j2[safe: index] ?? j2.last ?? 0.0,
            j3[safe: index] ?? j3.last ?? 0.0,
            j4[safe: index] ?? j4.last ?? 0.0,
            j5[safe: index] ?? j5.last ?? 0.0,
            j6[safe: index] ?? j6.last ?? 0.0,
        ]
    }

    /// Returns all 6 joint positions for a given sample index, converted to radians
    /// - Parameter index: The sample index (0..<sampleCount)
    /// - Returns: Array of 6 joint positions [j1, j2, j3, j4, j5, j6] in radians
    public func jointsInRadians(at index: Int) -> [Float] {
        joints(at: index).map { $0 * .pi / 180.0 }
    }

    // MARK: - Streaming Support

    /// Creates a streaming iterator for this waveform
    /// - Parameter posesPerBatch: Number of poses to return per batch (default: 5, which yields 30 floats)
    /// - Returns: A WaveformStreamer that can dequeue batches of poses
    public func makeStreamer(posesPerBatch: Int = 5) -> WaveformStreamer {
        WaveformStreamer(waveform: self, posesPerBatch: posesPerBatch)
    }
}

// MARK: - Waveform Streamer

/// Iterator for streaming batches of joint positions from a waveform
public class WaveformStreamer {
    private let waveform: URStreamWaveform
    private let posesPerBatch: Int
    private var currentIndex: Int = 0

    /// Total number of poses (samples) in the waveform
    public var totalPoses: Int { waveform.sampleCount }

    /// Current streaming index
    public var index: Int { currentIndex }

    /// Whether there are more poses to stream
    public var hasMore: Bool { currentIndex < waveform.sampleCount }

    /// Remaining poses in the waveform
    public var remaining: Int { max(0, waveform.sampleCount - currentIndex) }

    init(waveform: URStreamWaveform, posesPerBatch: Int) {
        self.waveform = waveform
        self.posesPerBatch = posesPerBatch
    }

    /// Resets the streaming index to the beginning
    public func reset() {
        currentIndex = 0
    }

    /// Dequeues the next batch of poses and returns them as a flat array of floats in radians
    /// - Parameter count: Number of poses to dequeue (defaults to posesPerBatch)
    /// - Returns: Flat array of joint positions [pose0_j0...pose0_j5, pose1_j0...pose1_j5, ...] in radians, or nil if no more data
    public func dequeueRadians(count: Int? = nil) -> [Float]? {
        let batchSize = count ?? posesPerBatch
        guard currentIndex < waveform.sampleCount else { return nil }

        var floats: [Float] = []
        floats.reserveCapacity(batchSize * 6)

        let endIndex = min(currentIndex + batchSize, waveform.sampleCount)
        for i in currentIndex..<endIndex {
            let joints = waveform.jointsInRadians(at: i)
            floats.append(contentsOf: joints)
        }

        currentIndex = endIndex
        return floats.isEmpty ? nil : floats
    }

    /// Dequeues the next batch of poses and returns them as a flat array of floats in degrees
    /// - Parameter count: Number of poses to dequeue (defaults to posesPerBatch)
    /// - Returns: Flat array of joint positions [pose0_j0...pose0_j5, pose1_j0...pose1_j5, ...] in degrees, or nil if no more data
    public func dequeueDegrees(count: Int? = nil) -> [Float]? {
        let batchSize = count ?? posesPerBatch
        guard currentIndex < waveform.sampleCount else { return nil }

        var floats: [Float] = []
        floats.reserveCapacity(batchSize * 6)

        let endIndex = min(currentIndex + batchSize, waveform.sampleCount)
        for i in currentIndex..<endIndex {
            let joints = waveform.joints(at: i)
            floats.append(contentsOf: joints)
        }

        currentIndex = endIndex
        return floats.isEmpty ? nil : floats
    }

    /// Dequeues the next batch and serializes it in URScript ASCII float format
    /// Format: "( value1, value2, ..., valueN )" where N = posesPerBatch * 6
    /// - Parameter count: Number of poses to dequeue (defaults to posesPerBatch)
    /// - Returns: Serialized string in URScript socket_read_ascii_float format, or nil if no more data
    public func dequeueURScriptFormat(count: Int? = nil) -> String? {
        guard let floats = dequeueRadians(count: count) else { return nil }

        // Format: ( value1, value2, value3, ..., valueN )
        let values = floats.map { String(format: "%.6f", $0) }.joined(separator: ", ")
        return "( \(values) )"
    }

    /// Peeks at the next batch without advancing the index
    /// - Parameter count: Number of poses to peek (defaults to posesPerBatch)
    /// - Returns: Flat array of joint positions in radians, or nil if no more data
    public func peekRadians(count: Int? = nil) -> [Float]? {
        let savedIndex = currentIndex
        let result = dequeueRadians(count: count)
        currentIndex = savedIndex
        return result
    }
}

// MARK: - Safe Array Subscript Extension

extension Array {
    fileprivate subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

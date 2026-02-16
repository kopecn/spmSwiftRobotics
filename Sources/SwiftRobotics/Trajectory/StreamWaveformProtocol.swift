import Foundation

/// Protocol for robot-agnostic joint streaming waveforms.
///
/// Conforming types provide sample-indexed joint positions that can be
/// streamed in batches via ``WaveformStreamer``.
public protocol StreamWaveformProtocol {
    /// The number of samples in this waveform.
    var sampleCount: Int { get }

    /// Returns all joint positions for a given sample index in degrees.
    /// - Parameter index: The sample index (0..<sampleCount)
    /// - Returns: Array of joint positions in degrees
    func joints(at index: Int) -> [Float]

    /// Returns all joint positions for a given sample index in radians.
    /// - Parameter index: The sample index (0..<sampleCount)
    /// - Returns: Array of joint positions in radians
    func jointsInRadians(at index: Int) -> [Float]
}

// MARK: - Default Implementation

extension StreamWaveformProtocol {
    /// Default implementation converting degrees to radians.
    public func jointsInRadians(at index: Int) -> [Float] {
        joints(at: index).map { $0 * .pi / 180.0 }
    }

    /// Creates a streaming iterator for this waveform.
    /// - Parameter posesPerBatch: Number of poses to return per batch (default: 5)
    /// - Returns: A ``WaveformStreamer`` that can dequeue batches of poses
    public func makeStreamer(posesPerBatch: Int = 5) -> WaveformStreamer<Self> {
        WaveformStreamer(waveform: self, posesPerBatch: posesPerBatch)
    }
}

import Foundation

/// Iterator for streaming batches of joint positions from a waveform.
///
/// Generic over any ``StreamWaveformProtocol`` conforming type, allowing
/// robot-agnostic waveform streaming.
///
/// - Note: Thread-safe. All public methods serialize access to the internal
///   index via an `NSLock`. A single `WaveformStreamer` may be shared across
///   threads — e.g., a background stream-fill thread calling `dequeueRadians`
///   while a UI thread calls `peekRadians`.
public class WaveformStreamer<W: StreamWaveformProtocol> {
    private let waveform: W
    private let posesPerBatch: Int
    private var currentIndex: Int = 0
    private let lock = NSLock()

    /// Total number of poses (samples) in the waveform
    public var totalPoses: Int { waveform.sampleCount }

    /// Current streaming index
    public var index: Int {
        lock.lock()
        defer { lock.unlock() }
        return currentIndex
    }

    /// Whether there are more poses to stream
    public var hasMore: Bool {
        lock.lock()
        defer { lock.unlock() }
        return currentIndex < waveform.sampleCount
    }

    /// Remaining poses in the waveform
    public var remaining: Int {
        lock.lock()
        defer { lock.unlock() }
        return max(0, waveform.sampleCount - currentIndex)
    }

    public init(waveform: W, posesPerBatch: Int) {
        self.waveform = waveform
        self.posesPerBatch = posesPerBatch
    }

    /// Resets the streaming index to the beginning
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        currentIndex = 0
    }

    /// Dequeues the next batch of poses and returns them as a flat array of floats in radians
    /// - Parameter count: Number of poses to dequeue (defaults to posesPerBatch)
    /// - Returns: Flat array of joint positions in radians, or nil if no more data
    public func dequeueRadians(count: Int? = nil) -> [Float]? {
        lock.lock()
        defer { lock.unlock() }
        return dequeueRadiansLocked(count: count)
    }

    /// Dequeues the next batch of poses and returns them as a flat array of floats in degrees
    /// - Parameter count: Number of poses to dequeue (defaults to posesPerBatch)
    /// - Returns: Flat array of joint positions in degrees, or nil if no more data
    public func dequeueDegrees(count: Int? = nil) -> [Float]? {
        lock.lock()
        defer { lock.unlock() }
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

    /// Peeks at the next batch without advancing the index
    /// - Parameter count: Number of poses to peek (defaults to posesPerBatch)
    /// - Returns: Flat array of joint positions in radians, or nil if no more data
    public func peekRadians(count: Int? = nil) -> [Float]? {
        lock.lock()
        defer { lock.unlock() }
        let savedIndex = currentIndex
        let result = dequeueRadiansLocked(count: count)
        currentIndex = savedIndex
        return result
    }

    // MARK: - Private

    /// Reads the next batch in radians without acquiring the lock.
    /// Must only be called while `lock` is held.
    private func dequeueRadiansLocked(count: Int?) -> [Float]? {
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
}

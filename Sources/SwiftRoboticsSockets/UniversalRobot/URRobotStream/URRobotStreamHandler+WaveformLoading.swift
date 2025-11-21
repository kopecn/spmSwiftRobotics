import SwiftRoboticAssets
import Foundation
import Logging

// MARK: - Waveform Management

extension URRobotStreamHandler {

    // MARK: - Load from Asset Bundle

    /// Loads a waveform from the assets bundle and creates a streamer
    /// - Parameters:
    ///   - resourceName: The name of the JSON waveform resource (without .json extension)
    ///   - posesPerBatch: Number of poses per batch (default: 5, which yields 30 floats)
    /// - Returns: True if the waveform was loaded successfully, false otherwise
    @discardableResult
    public func loadWaveform(
        fromResource resourceName: String,
        posesPerBatch: Int = 5
    ) -> Bool {
        guard let waveform = AssetLoader.loadJSON(
            forResource: resourceName,
            as: URStreamWaveform.self
        ) else {
            logger.error("🔴 Failed to load waveform: \(resourceName)")
            currentlyLoadedWaveform = nil
            return false
        }

        currentlyLoadedWaveform = waveform.makeStreamer(posesPerBatch: posesPerBatch)
        logger.info("🟢 Loaded waveform: \(waveform.metadata.name) (\(waveform.sampleCount) samples)")
        return true
    }

    /// Loads a waveform from the assets bundle with error handling
    /// - Parameters:
    ///   - resourceName: The name of the JSON waveform resource (without .json extension)
    ///   - posesPerBatch: Number of poses per batch (default: 5, which yields 30 floats)
    /// - Throws: AssetLoaderError if loading or decoding fails
    public func loadWaveformWithError(
        fromResource resourceName: String,
        posesPerBatch: Int = 5
    ) throws {
        let waveform = try AssetLoader.loadJSONWithError(
            forResource: resourceName,
            as: URStreamWaveform.self
        )

        currentlyLoadedWaveform = waveform.makeStreamer(posesPerBatch: posesPerBatch)
        logger.info("🟢 Loaded waveform: \(waveform.metadata.name) (\(waveform.sampleCount) samples)")
    }

    // MARK: - Load from URL

    /// Loads a waveform from a URL and creates a streamer
    /// - Parameters:
    ///   - url: The URL to the JSON waveform file
    ///   - posesPerBatch: Number of poses per batch (default: 5, which yields 30 floats)
    /// - Returns: True if the waveform was loaded successfully, false otherwise
    @discardableResult
    public func loadWaveform(
        fromURL url: URL,
        posesPerBatch: Int = 5
    ) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let waveform = try JSONDecoder().decode(URStreamWaveform.self, from: data)

            currentlyLoadedWaveform = waveform.makeStreamer(posesPerBatch: posesPerBatch)
            logger.info("🟢 Loaded waveform from URL: \(waveform.metadata.name) (\(waveform.sampleCount) samples)")
            return true
        } catch {
            logger.error("🔴 Failed to load waveform from URL: \(url.path) - \(error.localizedDescription)")
            currentlyLoadedWaveform = nil
            return false
        }
    }

    /// Loads a waveform from a URL with error handling
    /// - Parameters:
    ///   - url: The URL to the JSON waveform file
    ///   - posesPerBatch: Number of poses per batch (default: 5, which yields 30 floats)
    /// - Throws: Error if loading or decoding fails
    public func loadWaveformWithError(
        fromURL url: URL,
        posesPerBatch: Int = 5
    ) throws {
        let data = try Data(contentsOf: url)
        let waveform = try JSONDecoder().decode(URStreamWaveform.self, from: data)

        currentlyLoadedWaveform = waveform.makeStreamer(posesPerBatch: posesPerBatch)
        logger.info("🟢 Loaded waveform from URL: \(waveform.metadata.name) (\(waveform.sampleCount) samples)")
    }

    /// Unloads the current waveform
    public func unloadWaveform() {
        currentlyLoadedWaveform = nil
        logger.info("🟢 Waveform unloaded")
    }

    /// Resets the current waveform streamer to the beginning
    public func resetWaveform() {
        currentlyLoadedWaveform?.reset()
        logger.info("🟢 Waveform reset to start")
    }

    /// Returns the next batch of poses in URScript ASCII float format
    /// - Returns: Formatted string ready to send to robot, or nil if no waveform loaded or no more data
    public func dequeueNextBatch() -> String? {
        guard let batch = currentlyLoadedWaveform?.dequeueURScriptFormat() else {
            if currentlyLoadedWaveform == nil {
                logger.warning("⚠️ No waveform loaded")
            } else {
                logger.info("ℹ️ No more data in waveform")
            }
            return nil
        }
        return batch
    }

    /// Checks if there's more data to stream
    public var hasMoreData: Bool {
        currentlyLoadedWaveform?.hasMore ?? false
    }

    /// Returns the current streaming progress (0.0 to 1.0)
    public var streamingProgress: Double {
        guard let streamer = currentlyLoadedWaveform else { return 0.0 }
        guard streamer.totalPoses > 0 else { return 0.0 }
        return Double(streamer.index) / Double(streamer.totalPoses)
    }

    /// Returns streaming statistics
    public var streamingStats: (current: Int, total: Int, remaining: Int)? {
        guard let streamer = currentlyLoadedWaveform else { return nil }
        return (
            current: streamer.index,
            total: streamer.totalPoses,
            remaining: streamer.remaining
        )
    }
}

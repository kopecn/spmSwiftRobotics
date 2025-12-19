import Foundation
import Testing

/// Checks if UR simulator tests should be enabled
public struct URSimulatorAvailability {
    /// Returns true if simulator tests should run
    public static var isEnabled: Bool {
        // Check environment variable ENABLE_SIMULATOR_TESTS
        if let value = ProcessInfo.processInfo.environment["ENABLE_SIMULATOR_TESTS"] {
            return value.lowercased() == "true" || value == "1"
        }
        return false
    }

    /// Returns a condition for skipping simulator tests when not available
    public static var skipCondition: Bool {
        !isEnabled
    }
}

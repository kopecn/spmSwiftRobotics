import Foundation

/// Categories of transactional commands based on their execution behavior.
///
/// Commands are categorized by how they interact with the device resource:
/// - **Motion**: Blocking commands that move the device. Must be executed serially.
/// - **Query**: Non-blocking read-only commands. Can execute in parallel.
/// - **Settable**: Commands that modify device configuration values.
public enum TransactionalCommandCategory: String, Codable, Sendable {
    /// Motion commands are blocking and must be executed serially.
    ///
    /// These commands physically move the robot or automation element.
    /// While a motion command is executing, the device is in a `busy` state.
    /// Additional motion commands will be queued for sequential execution.
    case motion

    /// Query commands are non-blocking and can execute in parallel.
    ///
    /// These commands read device state without modifying it.
    /// Multiple query commands from different sources can execute simultaneously.
    case query

    /// Settable commands modify device configuration values.
    ///
    /// These commands set taught points, calibration values, or other
    /// persistent configuration. They are executed serially to prevent
    /// conflicting updates.
    case settable
}

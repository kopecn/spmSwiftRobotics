import Foundation

/// Represents the operational state of a device managed by a TransactionHandler.
///
/// The device state reflects both connectivity and operational readiness,
/// allowing clients to understand whether commands can be accepted.
public enum DeviceState: String, Codable, Sendable {
    /// Device is not connected or communication has not been established.
    case disconnected

    /// Device is connected and awaiting commands.
    ///
    /// In this state, the handler can accept new commands of any category.
    case idle

    /// Device is executing a motion command.
    ///
    /// Motion commands are blocking; additional motion commands will be queued.
    /// Query commands may still be accepted depending on device capability.
    case busy

    /// Device is in an error state and cannot accept commands.
    ///
    /// Recovery may require explicit reset or reconnection.
    case error

    /// Device is in emergency stop state.
    ///
    /// All motion is halted. Manual intervention may be required.
    case estop

    /// Device is initializing or performing startup routines.
    case initializing
}

/// Result of a transaction submission or execution.
public enum TransactionResult: Sendable {
    /// Transaction was acknowledged and is being processed.
    case acknowledged(transactionID: Int)

    /// Transaction completed successfully with optional response data.
    case completed(transactionID: Int, response: String?)

    /// Transaction failed with an error.
    case failed(transactionID: Int, error: TransactionError)

    /// Transaction timed out before receiving a response.
    case timedOut(transactionID: Int)

    /// Transaction was queued for later execution.
    case queued(transactionID: Int, position: Int)
}

/// Errors that can occur during transaction processing.
public enum TransactionError: Error, Sendable {
    /// Device is not in a state that accepts commands.
    case deviceNotReady(state: DeviceState)

    /// The command category is not supported for concurrent execution.
    case categoryConflict(requested: TransactionalCommandCategory, current: TransactionalCommandCategory)

    /// Transaction timed out waiting for acknowledgment.
    case acknowledgmentTimeout

    /// Transaction timed out waiting for completion response.
    case responseTimeout

    /// Device reported an error during command execution.
    case deviceError(message: String)

    /// Communication with the device was lost during transaction.
    case communicationLost

    /// Transaction was cancelled before completion.
    case cancelled

    /// Unknown or unexpected error.
    case unknown(underlying: Error?)
}

import Foundation
import OpenCombine

/// Represents the lifecycle state of a transaction.
public enum TransactionState: String, Codable, Sendable {
    /// Transaction has been created but not yet sent.
    case pending

    /// Transaction has been sent and is awaiting acknowledgment.
    case awaitingAck

    /// Transaction was acknowledged and is executing on the device.
    case executing

    /// Transaction has been queued behind other transactions.
    case queued

    /// Transaction completed successfully.
    case completed

    /// Transaction failed.
    case failed

    /// Transaction was cancelled.
    case cancelled

    /// Transaction timed out.
    case timedOut
}

/// A transaction wrapping a command sent to a device.
///
/// Tracks the full lifecycle of a command from submission through completion,
/// including timing, state transitions, and response handling.
public final class Transaction<Command: TransactionalCommand>: @unchecked Sendable {
    /// Unique identifier for this transaction.
    public let id: Int

    /// The command being transacted.
    public let command: Command

    /// The category of the command (motion, query, settable).
    public var category: TransactionalCommandCategory { command.commandType }

    /// Current state of the transaction.
    public private(set) var state: TransactionState

    /// Timestamp when the transaction was created.
    public let createdAt: Date

    /// Timestamp when the transaction was sent to the device.
    public private(set) var sentAt: Date?

    /// Timestamp when the acknowledgment was received.
    public private(set) var acknowledgedAt: Date?

    /// Timestamp when the transaction completed (success or failure).
    public private(set) var completedAt: Date?

    /// The response received from the device, if any.
    public private(set) var response: String?

    /// The error if the transaction failed.
    public private(set) var error: TransactionError?

    /// Timeout duration for this transaction in seconds.
    public let timeout: TimeInterval

    /// Publisher that emits state changes for this transaction.
    public let statePublisher: OpenCombine.CurrentValueSubject<TransactionState, Never>

    /// Publisher that emits the final result when the transaction completes.
    public let resultPublisher: OpenCombine.PassthroughSubject<TransactionResult, Never>

    /// Publisher that emits solicited events associated with this transaction.
    ///
    /// Solicited events are updates from the device during command execution,
    /// such as progress updates, waypoint notifications, or streaming data.
    /// Subscribe to receive real-time updates while the transaction executes.
    public let eventPublisher: OpenCombine.PassthroughSubject<DeviceEvent, Never>

    /// All events received for this transaction, in order.
    public private(set) var events: [DeviceEvent] = []

    private let lock = NSLock()

    /// Creates a new transaction for the given command.
    ///
    /// - Parameters:
    ///   - id: Unique transaction identifier.
    ///   - command: The command to transact.
    ///   - timeout: Timeout duration in seconds. Defaults to command's timeout or 30 seconds.
    public init(id: Int, command: Command, timeout: TimeInterval? = nil) {
        self.id = id
        self.command = command
        self.state = .pending
        self.createdAt = Date()
        self.timeout = timeout ?? TimeInterval(command.timeout ?? 30.0)
        self.statePublisher = CurrentValueSubject(.pending)
        self.resultPublisher = PassthroughSubject()
        self.eventPublisher = PassthroughSubject()
    }

    /// Marks the transaction as sent to the device.
    func markSent() {
        lock.lock()
        defer { lock.unlock() }
        sentAt = Date()
        updateState(.awaitingAck)
    }

    /// Marks the transaction as acknowledged by the device.
    func markAcknowledged() {
        lock.lock()
        defer { lock.unlock() }
        acknowledgedAt = Date()
        updateState(.executing)
        resultPublisher.send(.acknowledged(transactionID: id))
    }

    /// Marks the transaction as queued.
    ///
    /// - Parameter position: Position in the queue (0-indexed).
    func markQueued(position: Int) {
        lock.lock()
        defer { lock.unlock() }
        updateState(.queued)
        resultPublisher.send(.queued(transactionID: id, position: position))
    }

    /// Marks the transaction as completed successfully.
    ///
    /// - Parameter response: Optional response data from the device.
    func markCompleted(response: String? = nil) {
        lock.lock()
        defer { lock.unlock() }
        self.response = response
        completedAt = Date()
        updateState(.completed)
        resultPublisher.send(.completed(transactionID: id, response: response))
        resultPublisher.send(completion: .finished)
        eventPublisher.send(completion: .finished)
    }

    /// Marks the transaction as failed.
    ///
    /// - Parameter error: The error that caused the failure.
    func markFailed(error: TransactionError) {
        lock.lock()
        defer { lock.unlock() }
        self.error = error
        completedAt = Date()
        updateState(.failed)
        resultPublisher.send(.failed(transactionID: id, error: error))
        resultPublisher.send(completion: .finished)
        eventPublisher.send(completion: .finished)
    }

    /// Marks the transaction as timed out.
    func markTimedOut() {
        lock.lock()
        defer { lock.unlock() }
        self.error = state == .awaitingAck ? .acknowledgmentTimeout : .responseTimeout
        completedAt = Date()
        updateState(.timedOut)
        resultPublisher.send(.timedOut(transactionID: id))
        resultPublisher.send(completion: .finished)
        eventPublisher.send(completion: .finished)
    }

    /// Marks the transaction as cancelled.
    func markCancelled() {
        lock.lock()
        defer { lock.unlock() }
        self.error = .cancelled
        completedAt = Date()
        updateState(.cancelled)
        resultPublisher.send(.failed(transactionID: id, error: .cancelled))
        resultPublisher.send(completion: .finished)
        eventPublisher.send(completion: .finished)
    }

    /// Receives a solicited event for this transaction.
    ///
    /// - Parameter event: The event to process.
    func receiveEvent(_ event: DeviceEvent) {
        lock.lock()
        defer { lock.unlock() }
        events.append(event)
        eventPublisher.send(event)
    }

    /// Elapsed time since the transaction was sent, or nil if not yet sent.
    public var elapsedSinceSent: TimeInterval? {
        guard let sentAt = sentAt else { return nil }
        return Date().timeIntervalSince(sentAt)
    }

    /// Whether the transaction has exceeded its timeout.
    public var isTimedOut: Bool {
        guard let elapsed = elapsedSinceSent else { return false }
        return elapsed > timeout
    }

    /// Whether the transaction is in a terminal state (completed, failed, cancelled, timedOut).
    public var isTerminal: Bool {
        switch state {
        case .completed, .failed, .cancelled, .timedOut:
            return true
        case .pending, .awaitingAck, .executing, .queued:
            return false
        }
    }

    private func updateState(_ newState: TransactionState) {
        state = newState
        statePublisher.send(newState)
    }
}

extension Transaction: Hashable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

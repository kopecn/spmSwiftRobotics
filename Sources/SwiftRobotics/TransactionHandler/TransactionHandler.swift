import Foundation
import OpenCombine
import OpenCombineDispatch

/// A handler for managing transactional commands with a single device resource.
///
/// `TransactionHandler` provides composable transaction management for robots
/// and automation elements, supporting the command flow: cmd → ack → work → response.
///
/// ## Features
/// - **Isolated resource handling**: Each handler manages one device resource
/// - **Command categorization**: Motion (serial/blocking), Query (parallel), Settable (serial)
/// - **Timeout management**: Per-transaction and global timeout support
/// - **Device state tracking**: Monitors device readiness and operational state
/// - **OpenCombine integration**: All transactions managed via AnyCancellable
///
/// ## Usage
/// ```swift
/// let handler = TransactionHandler<RobotCommand>(resourceID: "robot-1")
///
/// // Submit a motion command (will be queued if device is busy)
/// let transaction = handler.submit(.home)
///
/// // Subscribe to transaction results
/// transaction.resultPublisher
///     .sink { result in
///         switch result {
///         case .completed(let id, let response):
///             print("Command \(id) completed: \(response ?? "no response")")
///         case .failed(let id, let error):
///             print("Command \(id) failed: \(error)")
///         default: break
///         }
///     }
///     .store(in: &cancellables)
/// ```
public final class TransactionHandler<Command: TransactionalCommand>: @unchecked Sendable {

    // MARK: - Public Properties

    /// Unique identifier for the resource this handler manages.
    public let resourceID: String

    /// Current state of the managed device.
    public var deviceState: DeviceState {
        deviceStateSubject.value
    }

    /// Publisher for device state changes.
    public var deviceStatePublisher: OpenCombine.AnyPublisher<DeviceState, Never> {
        deviceStateSubject.eraseToAnyPublisher()
    }

    /// Default timeout for transactions in seconds.
    public var defaultTimeout: TimeInterval = 30.0

    /// Maximum number of concurrent query transactions.
    public var maxConcurrentQueries: Int = 10

    /// Maximum queue depth for motion commands.
    public var maxMotionQueueDepth: Int = 100

    // MARK: - Private Properties

    private let deviceStateSubject: CurrentValueSubject<DeviceState, Never>
    private var cancellables = Set<AnyCancellable>()
    private let lock = NSRecursiveLock()

    /// Counter for generating unique transaction IDs.
    private var nextTransactionID: Int = 1

    /// Currently executing motion transaction (only one at a time).
    private var activeMotionTransaction: Transaction<Command>?

    /// Queue of pending motion transactions.
    private var motionQueue: [Transaction<Command>] = []

    /// Active query transactions (can run in parallel).
    private var activeQueryTransactions: [Int: Transaction<Command>] = [:]

    /// Active settable transaction (only one at a time, like motion).
    private var activeSettableTransaction: Transaction<Command>?

    /// Queue of pending settable transactions.
    private var settableQueue: [Transaction<Command>] = []

    /// All active transactions by ID for response routing.
    private var allActiveTransactions: [Int: Transaction<Command>] = [:]

    /// Timer subscriptions for transaction timeouts.
    private var timeoutTimers: [Int: AnyCancellable] = [:]

    /// Delegate for sending commands to the actual device.
    public weak var delegate: TransactionHandlerDelegate?

    // MARK: - Initialization

    /// Creates a new transaction handler for the specified resource.
    ///
    /// - Parameters:
    ///   - resourceID: Unique identifier for the device resource.
    ///   - initialState: Initial device state. Defaults to `.disconnected`.
    public init(resourceID: String, initialState: DeviceState = .disconnected) {
        self.resourceID = resourceID
        self.deviceStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - Public Methods

    /// Submits a command for transaction.
    ///
    /// The command will be processed according to its category:
    /// - **Motion**: Queued if another motion is active, executed serially
    /// - **Query**: Executed immediately in parallel with other queries
    /// - **Settable**: Queued if another settable is active, executed serially
    ///
    /// Transaction ID resolution (in priority order):
    /// 1. Command's `trID` if valid (>= 0)
    /// 2. Auto-generated unique ID
    ///
    /// Timeout resolution (in priority order):
    /// 1. Explicit `timeout` parameter passed to this method
    /// 2. Command's `timeout` property if defined
    /// 3. Handler's `defaultTimeout`
    ///
    /// - Parameters:
    ///   - command: The command to transact.
    ///   - timeout: Optional timeout override. If nil, uses command's timeout or handler default.
    /// - Returns: A `Transaction` object for tracking progress and subscribing to results.
    @discardableResult
    public func submit(_ command: Command, timeout: TimeInterval? = nil) -> Transaction<Command> {
        lock.lock()
        defer { lock.unlock() }

        // Use command's trID if valid, otherwise generate one
        let transactionID: Int
        if command.trID >= 0 {
            transactionID = command.trID
        } else {
            transactionID = nextTransactionID
            nextTransactionID += 1
        }

        // Resolve timeout: explicit parameter > command timeout > handler default
        let resolvedTimeout: TimeInterval
        if let explicitTimeout = timeout {
            resolvedTimeout = explicitTimeout
        } else if let commandTimeout = command.timeout {
            resolvedTimeout = TimeInterval(commandTimeout)
        } else {
            resolvedTimeout = defaultTimeout
        }

        let transaction = Transaction(
            id: transactionID,
            command: command,
            timeout: resolvedTimeout
        )

        allActiveTransactions[transactionID] = transaction

        switch command.commandType {
        case .motion:
            handleMotionSubmission(transaction)
        case .query:
            handleQuerySubmission(transaction)
        case .settable:
            handleSettableSubmission(transaction)
        }

        return transaction
    }

    /// Processes an acknowledgment received from the device.
    ///
    /// - Parameter transactionID: The ID of the acknowledged transaction.
    public func processAcknowledgment(transactionID: Int) {
        lock.lock()
        defer { lock.unlock() }

        guard let transaction = allActiveTransactions[transactionID] else { return }
        transaction.markAcknowledged()

        if transaction.category == .motion {
            updateDeviceState(.busy)
        }
    }

    /// Processes a response received from the device.
    ///
    /// - Parameters:
    ///   - transactionID: The ID of the completed transaction.
    ///   - response: Optional response data from the device.
    public func processResponse(transactionID: Int, response: String? = nil) {
        lock.lock()
        defer { lock.unlock() }

        guard let transaction = allActiveTransactions[transactionID] else { return }

        cancelTimeout(for: transactionID)
        transaction.markCompleted(response: response)
        cleanupTransaction(transaction)
        processNextInQueue(for: transaction.category)
    }

    /// Processes an error response from the device.
    ///
    /// - Parameters:
    ///   - transactionID: The ID of the failed transaction.
    ///   - message: Error message from the device.
    public func processError(transactionID: Int, message: String) {
        lock.lock()
        defer { lock.unlock() }

        guard let transaction = allActiveTransactions[transactionID] else { return }

        cancelTimeout(for: transactionID)
        transaction.markFailed(error: .deviceError(message: message))
        cleanupTransaction(transaction)
        processNextInQueue(for: transaction.category)
    }

    /// Updates the device state.
    ///
    /// - Parameter state: The new device state.
    public func updateDeviceState(_ state: DeviceState) {
        deviceStateSubject.send(state)

        if state == .error || state == .estop || state == .disconnected {
            cancelAllActiveTransactions(error: .deviceNotReady(state: state))
        }
    }

    /// Cancels a specific transaction.
    ///
    /// - Parameter transactionID: The ID of the transaction to cancel.
    public func cancel(transactionID: Int) {
        lock.lock()
        defer { lock.unlock() }

        guard let transaction = allActiveTransactions[transactionID] else { return }

        cancelTimeout(for: transactionID)
        transaction.markCancelled()
        cleanupTransaction(transaction)
        processNextInQueue(for: transaction.category)
    }

    /// Cancels all pending and active transactions.
    public func cancelAll() {
        lock.lock()
        defer { lock.unlock() }

        cancelAllActiveTransactions(error: .cancelled)
    }

    /// Returns the current queue depth for motion commands.
    public var motionQueueCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return motionQueue.count
    }

    /// Returns the count of active query transactions.
    public var activeQueryCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return activeQueryTransactions.count
    }

    /// Returns whether the handler is currently busy with a motion command.
    public var isMotionBusy: Bool {
        lock.lock()
        defer { lock.unlock() }
        return activeMotionTransaction != nil
    }

    // MARK: - Private Methods

    private func handleMotionSubmission(_ transaction: Transaction<Command>) {
        guard deviceState != .disconnected &&
              deviceState != .error &&
              deviceState != .estop else {
            transaction.markFailed(error: .deviceNotReady(state: deviceState))
            allActiveTransactions.removeValue(forKey: transaction.id)
            return
        }

        if activeMotionTransaction != nil {
            if motionQueue.count >= maxMotionQueueDepth {
                transaction.markFailed(error: .categoryConflict(requested: .motion, current: .motion))
                allActiveTransactions.removeValue(forKey: transaction.id)
                return
            }
            motionQueue.append(transaction)
            transaction.markQueued(position: motionQueue.count - 1)
        } else {
            executeMotion(transaction)
        }
    }

    private func handleQuerySubmission(_ transaction: Transaction<Command>) {
        guard deviceState != .disconnected &&
              deviceState != .error &&
              deviceState != .estop else {
            transaction.markFailed(error: .deviceNotReady(state: deviceState))
            allActiveTransactions.removeValue(forKey: transaction.id)
            return
        }

        if activeQueryTransactions.count >= maxConcurrentQueries {
            transaction.markFailed(error: .categoryConflict(requested: .query, current: .query))
            allActiveTransactions.removeValue(forKey: transaction.id)
            return
        }

        executeQuery(transaction)
    }

    private func handleSettableSubmission(_ transaction: Transaction<Command>) {
        guard deviceState != .disconnected &&
              deviceState != .error &&
              deviceState != .estop else {
            transaction.markFailed(error: .deviceNotReady(state: deviceState))
            allActiveTransactions.removeValue(forKey: transaction.id)
            return
        }

        if activeSettableTransaction != nil {
            settableQueue.append(transaction)
            transaction.markQueued(position: settableQueue.count - 1)
        } else {
            executeSettable(transaction)
        }
    }

    private func executeMotion(_ transaction: Transaction<Command>) {
        activeMotionTransaction = transaction
        sendToDevice(transaction)
    }

    private func executeQuery(_ transaction: Transaction<Command>) {
        activeQueryTransactions[transaction.id] = transaction
        sendToDevice(transaction)
    }

    private func executeSettable(_ transaction: Transaction<Command>) {
        activeSettableTransaction = transaction
        sendToDevice(transaction)
    }

    private func sendToDevice(_ transaction: Transaction<Command>) {
        transaction.markSent()
        startTimeout(for: transaction)

        let serialized = transaction.command.serialize(transactionID: String(transaction.id))
        delegate?.transactionHandler(self, sendCommand: serialized, transactionID: transaction.id)
    }

    private func startTimeout(for transaction: Transaction<Command>) {
        let transactionID = transaction.id
        let timeout = transaction.timeout

        let timer = DispatchQueue.OCombine(.global())
            .schedule(after: .init(.now() + timeout), interval: .seconds(Int(timeout)), tolerance: .milliseconds(100)) { [weak self] in
                self?.handleTimeout(transactionID: transactionID)
            }

        timeoutTimers[transactionID] = AnyCancellable { timer.cancel() }
    }

    private func cancelTimeout(for transactionID: Int) {
        timeoutTimers[transactionID]?.cancel()
        timeoutTimers.removeValue(forKey: transactionID)
    }

    private func handleTimeout(transactionID: Int) {
        lock.lock()
        defer { lock.unlock() }

        guard let transaction = allActiveTransactions[transactionID],
              !transaction.isTerminal else { return }

        transaction.markTimedOut()
        cleanupTransaction(transaction)
        processNextInQueue(for: transaction.category)
    }

    private func cleanupTransaction(_ transaction: Transaction<Command>) {
        allActiveTransactions.removeValue(forKey: transaction.id)

        switch transaction.category {
        case .motion:
            if activeMotionTransaction?.id == transaction.id {
                activeMotionTransaction = nil
                if motionQueue.isEmpty && deviceState == .busy {
                    updateDeviceState(.idle)
                }
            }
        case .query:
            activeQueryTransactions.removeValue(forKey: transaction.id)
        case .settable:
            if activeSettableTransaction?.id == transaction.id {
                activeSettableTransaction = nil
            }
        }
    }

    private func processNextInQueue(for category: TransactionalCommandCategory) {
        switch category {
        case .motion:
            if activeMotionTransaction == nil, let next = motionQueue.first {
                motionQueue.removeFirst()
                executeMotion(next)
            }
        case .query:
            break // Queries don't queue
        case .settable:
            if activeSettableTransaction == nil, let next = settableQueue.first {
                settableQueue.removeFirst()
                executeSettable(next)
            }
        }
    }

    private func cancelAllActiveTransactions(error: TransactionError) {
        for (id, transaction) in allActiveTransactions where !transaction.isTerminal {
            cancelTimeout(for: id)
            transaction.markFailed(error: error)
        }

        allActiveTransactions.removeAll()
        activeMotionTransaction = nil
        activeQueryTransactions.removeAll()
        activeSettableTransaction = nil

        for transaction in motionQueue {
            transaction.markFailed(error: error)
        }
        motionQueue.removeAll()

        for transaction in settableQueue {
            transaction.markFailed(error: error)
        }
        settableQueue.removeAll()
    }
}

// MARK: - Delegate Protocol

/// Delegate protocol for handling device communication.
///
/// Implement this protocol to connect the TransactionHandler to actual
/// device communication (sockets, serial ports, etc.).
public protocol TransactionHandlerDelegate: AnyObject {
    /// Called when the handler needs to send a command to the device.
    ///
    /// - Parameters:
    ///   - handler: The handler requesting the send.
    ///   - command: The serialized command string.
    ///   - transactionID: The transaction ID for response routing.
    func transactionHandler<Command: TransactionalCommand>(
        _ handler: TransactionHandler<Command>,
        sendCommand command: String,
        transactionID: Int
    )
}

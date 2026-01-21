import Foundation

// TODO: - Migrate this to spmFoundationTools - FoundationTypes such that it can be shared with spmNetworking and other such modules
// TODO: - Migrate this to spmFoundationTools - FoundationTypes such that it can be shared with spmNetworking and other such modules
// TODO: - Migrate this to spmFoundationTools - FoundationTypes such that it can be shared with spmNetworking and other such modules
// TODO: - Migrate this to spmFoundationTools - FoundationTypes such that it can be shared with spmNetworking and other such modules
// TODO: - Migrate this to spmFoundationTools - FoundationTypes such that it can be shared with spmNetworking and other such modules


// MARK: - Foundation Protocols (Candidates for spmFoundationTools)

/// A protocol for sending outbound messages.
///
/// Conforming types provide a mechanism to transmit string messages
/// to a remote endpoint (socket, serial port, etc.).
///
/// This is the outbound complement to `MessageHandling` (inbound).
public protocol TransactableMessageSending: AnyObject, Sendable {
    /// Sends a message to the remote endpoint.
    ///
    /// - Parameters:
    ///   - message: The message to send.
    ///   - priority: Optional priority for queue ordering. Higher values = higher priority.
    /// - Returns: Whether the message was sent or queued successfully.
    @discardableResult
    func send(_ message: String, priority: Int) -> Bool
}

extension TransactableMessageSending {
    /// Sends a message with default priority.
    @discardableResult
    public func send(_ message: String) -> Bool {
        send(message, priority: 0)
    }
}

/// A protocol for receiving inbound messages via callback assignment.
///
/// Conforming types allow a message handler to be assigned for processing
/// incoming messages. This complements `MessageHandling` by providing
/// the assignment mechanism rather than the handling itself.
public protocol TransactableMessageReceiving: AnyObject, Sendable {
    /// The type of handler that processes incoming messages.
    associatedtype Handler

    /// Assigns a handler for incoming messages.
    ///
    /// - Parameter handler: The handler to receive messages, or nil to clear.
    func setMessageHandler(_ handler: Handler?)
}

/// A bidirectional message pipe combining send and receive capabilities.
///
/// Conforming types provide full duplex communication, allowing both
/// outbound message transmission and inbound message reception.
///
/// ## Usage with TransactionHandler
/// ```swift
/// // Assign a socket client as the message pipe
/// let client = NIOSocketHandlerClient(...)
/// transactionHandler.attachPipe(client)
/// ```
public protocol MessagePipe: TransactableMessageSending, TransactableMessageReceiving {}

// MARK: - Callback-Based Message Pipe

/// A callback-based message pipe for flexible integration.
///
/// Use this when you need to bridge between systems using closures
/// rather than protocol conformance.
///
/// ## Example
/// ```swift
/// let pipe = CallbackMessagePipe(
///     sendHandler: { message, priority in
///         socketClient.send(message, priority: priority)
///         return true
///     },
///     receiveHandler: { callback in
///         socketClient.setMessageHandler(callback)
///     }
/// )
/// transactionHandler.attachPipe(pipe)
/// ```
public final class CallbackMessagePipe: MessagePipe, @unchecked Sendable {
    public typealias Handler = (@Sendable (String) async -> Void)?

    /// Callback invoked when sending a message.
    public var sendHandler: (@Sendable (String, Int) -> Bool)?

    /// Callback invoked to set the receive handler.
    public var receiveHandlerSetter: ((@Sendable (String) async -> Void)?) -> Void

    private let lock = NSLock()
    private var _messageHandler: Handler

    /// Creates a callback-based message pipe.
    ///
    /// - Parameters:
    ///   - sendHandler: Closure called when `send()` is invoked.
    ///   - receiveHandler: Closure called when `setMessageHandler()` is invoked.
    public init(
        sendHandler: (@Sendable (String, Int) -> Bool)? = nil,
        receiveHandler: @escaping ((@Sendable (String) async -> Void)?) -> Void = { _ in }
    ) {
        self.sendHandler = sendHandler
        self.receiveHandlerSetter = receiveHandler
        self._messageHandler = nil
    }

    @discardableResult
    public func send(_ message: String, priority: Int) -> Bool {
        sendHandler?(message, priority) ?? false
    }

    public func setMessageHandler(_ handler: ((@Sendable (String) async -> Void)?)?) {
        lock.lock()
        _messageHandler = handler ?? nil
        lock.unlock()
        receiveHandlerSetter(handler ?? nil)
    }
}

// MARK: - Transaction Handler Pipe Integration

/// Protocol for types that can be attached to a TransactionHandler as a communication pipe.
///
/// This allows the TransactionHandler to send serialized commands and receive
/// responses/events through a common interface.
public protocol TransactionPipe: AnyObject, Sendable {
    /// Sends a serialized command string to the device.
    ///
    /// - Parameters:
    ///   - command: The serialized command string.
    ///   - transactionID: The transaction ID for correlation.
    /// - Returns: Whether the send was successful or queued.
    @discardableResult
    func sendCommand(_ command: String, transactionID: Int) -> Bool

    /// Sets the handler for incoming messages from the device.
    ///
    /// The handler receives raw message strings that should be parsed
    /// and routed to `processAcknowledgment`, `processResponse`,
    /// `processError`, or `processEvent` on the TransactionHandler.
    ///
    /// - Parameter handler: Closure that receives incoming message strings.
    func setInboundHandler(_ handler: (@Sendable (String) async -> Void)?)
}

// MARK: - Adapter for MessagePipe -> TransactionPipe

/// Adapts a generic `MessagePipe` to work as a `TransactionPipe`.
///
/// This adapter bridges the generic message pipe interface to the
/// transaction-specific interface expected by TransactionHandler.
public final class MessagePipeAdapter<Pipe: MessagePipe>: TransactionPipe, @unchecked Sendable
    where Pipe.Handler == (@Sendable (String) async -> Void)?
{
    private let pipe: Pipe

    public init(_ pipe: Pipe) {
        self.pipe = pipe
    }

    @discardableResult
    public func sendCommand(_ command: String, transactionID: Int) -> Bool {
        (pipe as any TransactableMessageSending).send(command, priority: 0)
    }

    public func setInboundHandler(_ handler: (@Sendable (String) async -> Void)?) {
        pipe.setMessageHandler(handler)
    }
}

import Foundation
import FoundationInterfaces


// MARK: - FIXME -- Remove TransactionPipe and migrate to FoundationInterfaces MessageReceivable and MessageSendable
// MARK: - FIXME -- Remove TransactionPipe and migrate to FoundationInterfaces MessageReceivable and MessageSendable
// MARK: - FIXME -- Remove TransactionPipe and migrate to FoundationInterfaces MessageReceivable and MessageSendable
// MARK: - FIXME -- Remove TransactionPipe and migrate to FoundationInterfaces MessageReceivable and MessageSendable
// MARK: - FIXME -- Remove TransactionPipe and migrate to FoundationInterfaces MessageReceivable and MessageSendable
// MARK: - FIXME -- Remove TransactionPipe and migrate to FoundationInterfaces MessageReceivable and MessageSendable

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

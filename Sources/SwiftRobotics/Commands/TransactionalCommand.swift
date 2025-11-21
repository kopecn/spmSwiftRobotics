/// A protocol for commands that can be serialized into transactional protocol format.
///
/// Transactional commands support both terminal-based string serialization
/// (e.g., `<trID,command,arg1,arg2,...>`) and JSON encoding via Codable.
///
/// Example terminal format:
/// ```
/// <123,home,>
/// <456,moveto,1.57,-1.57,0.0,0.0,1.57,0.0>
/// ```
public protocol TransactionalCommand: Codable, Sendable {
    /// The command identifier string.
    var commandString: String { get }

    /// Arguments for the command. Empty array if no arguments.
    var arguments: [String] { get }

    /// Serializes the command into terminal transaction format.
    ///
    /// - Parameter transactionID: The transaction ID to include in the serialized format.
    /// - Returns: A string in the format `<transactionID,command,arg1,arg2,...>`
    func serialize(transactionID: String) -> String
}

// MARK: - Default Implementation

extension TransactionalCommand {
    /// Default serialization implementation for terminal protocol.
    ///
    /// Formats the command as: `<transactionID,command,arg1,arg2,...>`
    ///
    /// Examples:
    /// - Command with no args: `<123,home,>`
    /// - Command with args: `<456,moveto,1.57,-1.57,0.0>`
    public func serialize(transactionID: String) -> String {
        var components = [transactionID, commandString]
        components.append(contentsOf: arguments)
        let content = components.joined(separator: ",")
        return "<\(content),>"
    }
}

import Foundation

/// A parsed UR robot protocol message.
///
/// UR robot responses use the format: `<trID,type,code[,verbiage]>`
/// - `trID`: Transaction identifier (integer)
/// - `type`: Message type — `ack`, `res`, or `evt`
/// - `code`: Integer status code (0 = success, non-zero = error)
/// - `verbiage`: Optional human-readable description
public struct URProtocolMessage: Sendable {

    /// The transaction ID from the message, or nil if the field was absent or unparseable.
    public let trID: Int?

    /// The parsed message type.
    public let type: MessageType

    /// The status code (0 = success).
    public let code: Int

    /// Optional human-readable payload.
    public let verbiage: String?

    public enum MessageType: Sendable {
        case ack
        case res
        case evt
        case unknown(String)
    }
}

/// Parses raw UR robot protocol message strings into ``URProtocolMessage`` values.
///
/// The UR protocol uses angle-bracket-delimited, comma-separated frames:
/// ```
/// <42,ack,0>
/// <42,res,0,pose=[0.1,-0.5,0.3]>
/// <0,evt,1001,collision detected>
/// ```
///
/// This type is a pure function with no side effects, making it independently testable.
public enum URProtocolMessageParser {

    /// Parses a UR protocol message string.
    ///
    /// - Parameter message: The raw string received from the robot.
    /// - Returns: A ``URProtocolMessage`` if the string is parseable, or `nil` if
    ///   it contains fewer than 3 comma-separated fields after stripping angle brackets.
    public static func parse(_ message: String) -> URProtocolMessage? {
        var trimmed = message.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("<") && trimmed.hasSuffix(">") {
            trimmed = String(trimmed.dropFirst().dropLast())
        }

        let parts = trimmed
            .split(separator: ",", maxSplits: 3)
            .map { String($0).trimmingCharacters(in: .whitespaces) }

        guard parts.count >= 3 else { return nil }

        let trID = Int(parts[0])
        let typeString = parts[1].lowercased()
        let code = Int(parts[2]) ?? -1
        let verbiage = parts.count > 3 ? parts[3] : nil

        let type: URProtocolMessage.MessageType
        switch typeString {
        case "ack": type = .ack
        case "res": type = .res
        case "evt": type = .evt
        default: type = .unknown(parts[1])
        }

        return URProtocolMessage(trID: trID, type: type, code: code, verbiage: verbiage)
    }
}

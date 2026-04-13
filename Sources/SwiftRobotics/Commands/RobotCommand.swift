import FoundationTransactions

/// A generic, extensible robot command supporting transaction-based protocols.
///
/// `RobotCommand` provides a flexible command system that can be:
/// - Extended with custom commands via static properties
/// - Serialized to terminal transaction format (`<trID,command,args>`)
/// - Encoded/decoded as JSON via Codable
///
/// ## Built-in Common Commands
/// Use the provided static properties for standard robot operations:
/// ```swift
/// handler.send(.initRobot)
/// handler.send(.home)
/// handler.send(.status)
/// ```
///
/// ## Custom Commands
/// Extend `RobotCommand` with robot-specific or custom commands:
/// ```swift
/// extension RobotCommand {
///     static let customMove = RobotCommand("customMove", arguments: ["1.5", "2.0"])
/// }
/// handler.send(.customMove)
/// ```
///
/// ## Transaction Serialization
/// Commands can be serialized to terminal protocol format:
/// ```swift
/// let cmd = RobotCommand.home
/// let serialized = cmd.serialize(transactionID: "123")
/// // Result: "<123,home,>"
/// ```
///
/// ## JSON Serialization
/// Commands are Codable and can be serialized to/from JSON:
/// ```swift
/// let encoder = JSONEncoder()
/// let data = try encoder.encode(RobotCommand.home)
/// let decoded = try JSONDecoder().decode(RobotCommand.self, from: data)
/// ```
public struct RobotCommand: TransactionalCommand {
    /// The command identifier string.
    public let commandString: String

    /// Arguments for the command. Empty array if no arguments.
    public let arguments: [String]

    /// Optional timeout in seconds
    public let timeout: Float?

    public var trID: Int

    public var commandType: TransactionConcurrency

    /// Resource identifier for the target device/robot.
    public let resourceID: String?

    /// Creates a new robot command.
    ///
    /// - Parameters:
    ///   - commandString: The command identifier string.
    ///   - arguments: Optional arguments for the command. Defaults to empty array.
    ///   - timeout: Optional timeout in seconds.
    ///   - trID: Optional transaction ID.
    ///   - resourceID: Optional resource identifier for routing to specific device.
    public init(
        _ commandString: String,
        arguments: [String] = [],
        timeout: Float? = nil,
        trID: Int? = nil,
        resourceID: String? = nil,
        commandType: TransactionConcurrency = .serial
    ) {
        self.commandString = commandString
        self.arguments = arguments
        self.timeout = timeout
        self.trID = trID ?? -1
        self.resourceID = resourceID
        self.commandType = commandType
    }

    /// Returns the raw command string (without arguments).
    ///
    /// Useful for logging and debugging.
    public var rawValue: String {
        commandString
    }
}

// MARK: - Equatable, Hashable

extension RobotCommand: Equatable, Hashable {
    public static func == (lhs: RobotCommand, rhs: RobotCommand) -> Bool {
        lhs.commandString == rhs.commandString && lhs.arguments == rhs.arguments
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(commandString)
        hasher.combine(arguments)
    }
}

// MARK: - Common Robot Commands

extension RobotCommand {
    /// Initializes the robot system.
    ///
    /// Standard command supported by all robot types.
    public static let initRobot = RobotCommand(
        "initRobot",
        commandType: .serial
    )

    /// Moves the robot to its home position.
    ///
    /// Standard command supported by all robot types.
    public static let home = RobotCommand(
        "home",
        commandType: .serial
    )

    /// Requests the robot's status.
    ///
    /// Standard command supported by all robot types.
    public static let status = RobotCommand(
        "status",
        commandType: .parallel
    )

    /// Requests the robot's version information.
    public static let ver = RobotCommand(
        "ver",
        commandType: .parallel
    )

    /// Requests the robot's current TCP pose.
    public static let currentpose = RobotCommand(
        "currentpose",
        commandType: .parallel
    )

    /// Requests the robot's current joint posture.
    public static let currentposture = RobotCommand(
        "currentposture",
        commandType: .parallel
    )

    /// Starts streaming mode for high-frequency motion control.
    public static let startstreaming = RobotCommand(
        "startstreaming",
        commandType: .serial
    )

    /// Stops streaming mode and clears the motion buffer.
    public static let stopstreaming = RobotCommand(
        "stopstreaming",
        commandType: .serial
    )
}

// MARK: - CustomStringConvertible

extension RobotCommand: CustomStringConvertible {
    public var description: String {
        if arguments.isEmpty {
            return commandString
        } else {
            return "\(commandString)(\(arguments.joined(separator: ", ")))"
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension RobotCommand: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

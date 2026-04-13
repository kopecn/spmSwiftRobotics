import FoundationTransactions
import SwiftRobotics

public struct URRobotCommands: TransactionalCommand {
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

extension URRobotCommands: Equatable, Hashable {
    public static func == (lhs: URRobotCommands, rhs: URRobotCommands) -> Bool {
        lhs.commandString == rhs.commandString && lhs.arguments == rhs.arguments
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(commandString)
        hasher.combine(arguments)
    }
}

// MARK: - Common Robot Commands

extension URRobotCommands {
    /// Initializes the robot system.
    public static let initRobot = URRobotCommands(
        "initRobot",
        commandType: .serial
    )

    /// Moves the robot to its home position.
    public static let home = URRobotCommands(
        "home",
        commandType: .serial
    )

    /// Requests the robot's status.
    public static let status = URRobotCommands(
        "status",
        commandType: .parallel
    )

    /// Requests the robot's version information.
    public static let ver = URRobotCommands(
        "ver",
        commandType: .parallel
    )

    /// Requests the robot's current TCP pose.
    public static let currentpose = URRobotCommands(
        "currentpose",
        commandType: .parallel
    )

    /// Requests the robot's current joint posture.
    public static let currentposture = URRobotCommands(
        "currentposture",
        commandType: .parallel
    )

    /// Starts streaming mode for high-frequency motion control.
    public static let startstreaming = URRobotCommands(
        "startstreaming",
        commandType: .serial
    )

    /// Stops streaming mode and clears the motion buffer.
    public static let stopstreaming = URRobotCommands(
        "stopstreaming",
        commandType: .serial
    )
}

// MARK: - CustomStringConvertible

extension URRobotCommands: CustomStringConvertible {
    public var description: String {
        if arguments.isEmpty {
            return commandString
        } else {
            return "\(commandString)(\(arguments.joined(separator: ", ")))"
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension URRobotCommands: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

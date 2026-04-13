import Foundation
import Testing

@testable import SwiftRobotics

// MARK: - RobotCommand Serialization Tests

@Suite("RobotCommand Tests")
struct RobotCommandTests {

    // MARK: - Serialization

    @Test("Serializes command with no arguments")
    func testSerializeNoArgs() {
        let cmd = RobotCommand("home")
        let serialized = cmd.serialize(transactionID: "42")
        #expect(serialized == "<42,home,>")
    }

    @Test("Serializes command with arguments")
    func testSerializeWithArgs() {
        let cmd = RobotCommand("moveto", arguments: ["1.57", "-0.5", "0.0"])
        let serialized = cmd.serialize(transactionID: "7")
        #expect(serialized == "<7,moveto,1.57,-0.5,0.0,>")
    }

    @Test("Serializes command with single argument")
    func testSerializeSingleArg() {
        let cmd = RobotCommand("setspeed", arguments: ["0.5"])
        #expect(cmd.serialize(transactionID: "1") == "<1,setspeed,0.5,>")
    }

    // MARK: - Static commands

    @Test("Static commands have correct commandString")
    func testStaticCommandStrings() {
        #expect(RobotCommand.initRobot.commandString == "initRobot")
        #expect(RobotCommand.home.commandString == "home")
        #expect(RobotCommand.status.commandString == "status")
        #expect(RobotCommand.ver.commandString == "ver")
        #expect(RobotCommand.currentpose.commandString == "currentpose")
        #expect(RobotCommand.currentposture.commandString == "currentposture")
        #expect(RobotCommand.startstreaming.commandString == "startstreaming")
        #expect(RobotCommand.stopstreaming.commandString == "stopstreaming")
    }

    @Test("Serial commands have correct category")
    func testSerialCommandCategory() {
        #expect(RobotCommand.initRobot.commandType == .serial)
        #expect(RobotCommand.home.commandType == .serial)
        #expect(RobotCommand.startstreaming.commandType == .serial)
        #expect(RobotCommand.stopstreaming.commandType == .serial)
    }

    @Test("Parallel commands have correct category")
    func testParallelCommandCategory() {
        #expect(RobotCommand.status.commandType == .parallel)
        #expect(RobotCommand.ver.commandType == .parallel)
        #expect(RobotCommand.currentpose.commandType == .parallel)
        #expect(RobotCommand.currentposture.commandType == .parallel)
    }

    @Test("Static commands have empty arguments")
    func testStaticCommandsHaveNoArgs() {
        let staticCmds: [RobotCommand] = [
            .initRobot, .home, .status, .ver,
            .currentpose, .currentposture, .startstreaming, .stopstreaming,
        ]
        for cmd in staticCmds {
            #expect(cmd.arguments.isEmpty, "\(cmd.commandString) should have no arguments")
        }
    }

    @Test("Default trID is -1")
    func testDefaultTrIDIsNegativeOne() {
        let cmd = RobotCommand("test")
        #expect(cmd.trID == -1)
    }

    @Test("Custom trID is respected")
    func testCustomTrID() {
        let cmd = RobotCommand("test", trID: 42)
        #expect(cmd.trID == 42)
    }

    // MARK: - ExpressibleByStringLiteral

    @Test("String literal initializer sets commandString")
    func testStringLiteralInit() {
        let cmd: RobotCommand = "ping"
        #expect(cmd.commandString == "ping")
        #expect(cmd.arguments.isEmpty)
    }

    // MARK: - Equatable

    @Test("Commands with same string and args are equal")
    func testEquality() {
        let a = RobotCommand("move", arguments: ["1.0"])
        let b = RobotCommand("move", arguments: ["1.0"])
        #expect(a == b)
    }

    @Test("Commands with different args are not equal")
    func testInequalityArgs() {
        let a = RobotCommand("move", arguments: ["1.0"])
        let b = RobotCommand("move", arguments: ["2.0"])
        #expect(a != b)
    }

    @Test("Commands with different names are not equal")
    func testInequalityName() {
        let a = RobotCommand("home")
        let b = RobotCommand("stop")
        #expect(a != b)
    }

    // MARK: - description

    @Test("Description shows commandString when no args")
    func testDescriptionNoArgs() {
        let cmd = RobotCommand("home")
        #expect(cmd.description == "home")
    }

    @Test("Description shows commandString with args in parens")
    func testDescriptionWithArgs() {
        let cmd = RobotCommand("moveto", arguments: ["1.0", "2.0"])
        #expect(cmd.description == "moveto(1.0, 2.0)")
    }

    // MARK: - JSON Codable

    @Test("Round-trips through JSON encoding")
    func testJSONRoundTrip() throws {
        let original = RobotCommand("customCmd", arguments: ["a", "b"], timeout: 5.0, trID: 7)
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(RobotCommand.self, from: data)

        #expect(decoded.commandString == original.commandString)
        #expect(decoded.arguments == original.arguments)
        #expect(decoded.timeout == original.timeout)
        #expect(decoded.trID == original.trID)
    }

    // MARK: - Serialization format correctness

    @Test("Serialize wraps content in angle brackets")
    func testSerializeAngleBrackets() {
        let cmd = RobotCommand("test")
        let result = cmd.serialize(transactionID: "1")
        #expect(result.hasPrefix("<"))
        #expect(result.hasSuffix(">"))
    }

    @Test("Serialize places trID first")
    func testSerializeTrIDFirst() {
        let cmd = RobotCommand("cmd")
        let result = cmd.serialize(transactionID: "99")
        #expect(result.hasPrefix("<99,"))
    }
}

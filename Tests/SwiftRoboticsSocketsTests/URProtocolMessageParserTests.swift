import Testing

@testable import SwiftRoboticsSockets

// MARK: - URProtocolMessageParser Unit Tests

@Suite("URProtocolMessageParser Tests")
struct URProtocolMessageParserTests {

    // MARK: - ACK messages

    @Test("Parses valid ACK success message")
    func testParseAckSuccess() {
        let msg = URProtocolMessageParser.parse("<42,ack,0>")
        #expect(msg != nil)
        #expect(msg?.trID == 42)
        if case .ack = msg?.type {} else { Issue.record("Expected .ack type") }
        #expect(msg?.code == 0)
        #expect(msg?.verbiage == nil)
    }

    @Test("Parses ACK error with verbiage")
    func testParseAckError() {
        let msg = URProtocolMessageParser.parse("<7,ack,1,invalid command>")
        #expect(msg?.trID == 7)
        if case .ack = msg?.type {} else { Issue.record("Expected .ack") }
        #expect(msg?.code == 1)
        #expect(msg?.verbiage == "invalid command")
    }

    // MARK: - RES messages

    @Test("Parses valid RES success message with verbiage")
    func testParseResWithVerbiage() {
        let msg = URProtocolMessageParser.parse("<10,res,0,pose=[0.1,-0.5,0.3]>")
        #expect(msg?.trID == 10)
        if case .res = msg?.type {} else { Issue.record("Expected .res") }
        #expect(msg?.code == 0)
        #expect(msg?.verbiage == "pose=[0.1,-0.5,0.3]")
    }

    @Test("Parses RES success with no verbiage")
    func testParseResNoVerbiage() {
        let msg = URProtocolMessageParser.parse("<3,res,0>")
        #expect(msg?.trID == 3)
        if case .res = msg?.type {} else { Issue.record("Expected .res") }
        #expect(msg?.code == 0)
        #expect(msg?.verbiage == nil)
    }

    // MARK: - EVT messages

    @Test("Parses EVT with transaction ID")
    func testParseEvtWithTrID() {
        let msg = URProtocolMessageParser.parse("<0,evt,1001,collision detected>")
        #expect(msg?.trID == 0)
        if case .evt = msg?.type {} else { Issue.record("Expected .evt") }
        #expect(msg?.code == 1001)
        #expect(msg?.verbiage == "collision detected")
    }

    @Test("Parses EVT without verbiage")
    func testParseEvtNoVerbiage() {
        let msg = URProtocolMessageParser.parse("<0,evt,500>")
        if case .evt = msg?.type {} else { Issue.record("Expected .evt") }
        #expect(msg?.code == 500)
        #expect(msg?.verbiage == nil)
    }

    // MARK: - Case insensitivity

    @Test("Type matching is case-insensitive")
    func testCaseInsensitive() {
        let ack = URProtocolMessageParser.parse("<1,ACK,0>")
        if case .ack = ack?.type {} else { Issue.record("Expected .ack for uppercase ACK") }

        let res = URProtocolMessageParser.parse("<2,RES,0>")
        if case .res = res?.type {} else { Issue.record("Expected .res for uppercase RES") }

        let evt = URProtocolMessageParser.parse("<3,EVT,100>")
        if case .evt = evt?.type {} else { Issue.record("Expected .evt for uppercase EVT") }
    }

    // MARK: - Angle bracket stripping

    @Test("Strips angle brackets")
    func testAngleBrackets() {
        let withBrackets = URProtocolMessageParser.parse("<5,ack,0>")
        let withoutBrackets = URProtocolMessageParser.parse("5,ack,0")
        #expect(withBrackets?.trID == withoutBrackets?.trID)
        #expect(withBrackets?.code == withoutBrackets?.code)
    }

    // MARK: - Unknown type

    @Test("Returns .unknown for unrecognized type string")
    func testUnknownType() {
        let msg = URProtocolMessageParser.parse("<1,xyz,0>")
        if case .unknown(let s) = msg?.type {
            #expect(s == "xyz")
        } else {
            Issue.record("Expected .unknown type")
        }
    }

    // MARK: - Invalid / malformed input

    @Test("Returns nil for fewer than 3 fields")
    func testTooFewFields() {
        #expect(URProtocolMessageParser.parse("<1,ack>") == nil)
        #expect(URProtocolMessageParser.parse("<1>") == nil)
        #expect(URProtocolMessageParser.parse("") == nil)
        #expect(URProtocolMessageParser.parse("<>") == nil)
    }

    @Test("Handles non-integer trID (returns nil trID)")
    func testNonIntegerTrID() {
        let msg = URProtocolMessageParser.parse("<abc,ack,0>")
        #expect(msg != nil, "Should still parse; trID just becomes nil")
        #expect(msg?.trID == nil)
        if case .ack = msg?.type {} else { Issue.record("Expected .ack") }
    }

    @Test("Handles non-integer code (defaults to -1)")
    func testNonIntegerCode() {
        let msg = URProtocolMessageParser.parse("<1,ack,bad>")
        #expect(msg?.code == -1)
    }

    // MARK: - Whitespace handling

    @Test("Trims whitespace from fields")
    func testWhitespaceTrimming() {
        let msg = URProtocolMessageParser.parse("< 5 , ack , 0 >")
        #expect(msg?.trID == 5)
        if case .ack = msg?.type {} else { Issue.record("Expected .ack") }
        #expect(msg?.code == 0)
    }

    // MARK: - Verbiage with commas

    @Test("Verbiage containing commas is preserved intact")
    func testVerbiageWithCommas() {
        let msg = URProtocolMessageParser.parse("<1,res,0,x=1.0,y=2.0,z=3.0>")
        #expect(msg?.verbiage == "x=1.0,y=2.0,z=3.0")
    }
}

# Sockets

Full architecture reference: `Sources/SwiftRoboticsSockets/UniversalRobot/readme.md`

## Four Handler Architecture

| Handler | Pattern | Port | Purpose |
|---------|---------|------|---------|
| `URRobotCommandHandler` | Server (robot connects to Swift) | 50001 | Transaction-based discrete commands |
| `URRobotStreamHandler` | Server (robot connects to Swift) | 50002 | High-frequency buffer refill (500Hz) |
| `URRobotDashboardHandler` | Client (Swift connects to robot) | 29999 | Status queries, safety state |
| `URRobotScriptHandler` | Client (Swift connects to robot) | 30001 | URScript upload and execution |

All ports are defined in `URNetworkConfiguration` (`Sources/SwiftRoboticsSockets/Support/URNetworkConfiguration.swift`).

## URNetworkConfiguration

```swift
public enum URNetworkConfiguration {
    public static let commandPort: Int = 50001
    public static let streamPort: Int = 50002
    public static let scriptPort: Int = 30001
    public static let dashboardPort: Int = 29999
    public static let maxTransactionID: Int = 899
}
```

## Command Protocol

`URRobotCommandHandler` uses `TransactionHandler<URRobotCommands>` (from `FoundationTransactions`).

Frame format: `<trID,type,code[,verbiage]>`
- `type`: `ack`, `res`, `evt`
- Transaction IDs: 1–899 (wrapping), managed by `TransactionHandler`

`URProtocolMessageParser` parses these frames (`Sources/SwiftRoboticsSockets/UniversalRobot/URRobotCommand/URProtocolMessageParser.swift`).

Available commands: see `URRobotCommands.swift` (init, home, startstreaming, etc.)

### TransactionHandler wiring (command handler pattern)

```swift
handler.messageParser = { handler, message in
    guard let parsed = URProtocolMessageParser.parse(message) else { return }
    switch parsed.type {
    case .ack: handler.processAcknowledgment(transactionID: parsed.trID!)
    case .res: handler.processResponse(transactionID: parsed.trID!, response: parsed.verbiage)
    case .evt: handler.processEvent(code: parsed.code, payload: parsed.verbiage, transactionID: parsed.trID)
    default: break
    }
}
```

## Stream Protocol

`URRobotStreamHandler` manages the ring buffer refill loop:
- Robot maintains a 250-pose ring buffer (0.5s at 500Hz)
- Refill threshold triggers request back to Swift host
- Swift sends 30 floats (5 poses × 6 joints) per refill packet
- `URStreamWaveform` + `WaveformStreamer<URStreamWaveform>` generate the batches

## ResourceState / Connection State

All handlers expose `connectionState: ResourceState` publisher (from `FoundationTransactions`).

| State | Meaning |
|-------|---------|
| `.disconnected` | No socket connection |
| `.idle` | Connected, ready for commands |
| `.busy` | Executing a serial command |
| `.error` | Communication error (manual reconnect required — auto-reconnect not yet implemented) |
| `.estop` | Emergency stop active |
| `.initializing` | Startup routines in progress |

## Docker / URSim Validation

See `Sources/SwiftRoboticsSockets/UniversalRobot/readme.md` for the full Docker setup and port mapping to run the UR e-series simulator.

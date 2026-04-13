# TransactionHandler

A composable transaction management system for robot and automation device communication. Lives in `spmFoundationTools/FoundationTransactions`. Import `FoundationTransactions` to use it.

## Overview

`TransactionHandler` provides isolated, type-safe transaction handling for devices following the command-acknowledgment-response protocol pattern:

```
cmd → ack → (work) → response
```

Each handler manages a single resource, allowing multiple handlers to coexist for different devices while maintaining isolation.

## Concurrency Categories

Commands declare their category via `TransactionConcurrency` on `TransactionalCommand`:

| Category | Execution | Queueing | Use Case |
|----------|-----------|----------|----------|
| `.serial` | One at a time, blocking | Queued up to `maxSerialQueueDepth` | Physical movement commands (home, moveto) |
| `.parallel` | Concurrent | Up to `maxConcurrentParallel` | Read-only status queries (status, currentpose) |
| `.exclusive` | One at a time, independent queue | Queued separately from serial | Configuration commands that shouldn't block motion |

## Resource States

Managed by `ResourceState`:

| State | Description | Command Acceptance |
|-------|-------------|-------------------|
| `.disconnected` | No communication established | None — commands fail immediately |
| `.idle` | Ready for commands | All categories |
| `.busy` | Executing a serial command | All categories (serial are queued) |
| `.error` | Device error state | None — cancels all active transactions |
| `.estop` | Emergency stop active | None — cancels all active transactions |
| `.initializing` | Startup routines | All categories |

## Usage

### Basic Setup

```swift
import FoundationTransactions

let handler = TransactionHandler<RobotCommand>(resourceID: "robot-1")
handler.attachPipe(mySocket)
handler.updateResourceState(.idle)
```

### Submitting Commands

```swift
// Serial command — queued if another serial command is active
let moveTransaction = handler.submit(.home)

// Parallel command — runs concurrently with other parallel commands
let statusCmd = RobotCommand("status", commandType: .parallel)
let statusTransaction = handler.submit(statusCmd)

// Subscribe to results
moveTransaction.resultPublisher
    .sink { result in
        switch result {
        case .acknowledged(let id): print("Command \(id) acknowledged")
        case .completed(let id, let response): print("Command \(id) completed: \(response ?? "")")
        case .failed(let id, let error): print("Command \(id) failed: \(error)")
        case .queued(let id, let position): print("Command \(id) queued at position \(position)")
        case .timedOut(let id): print("Command \(id) timed out")
        case .cancelled(let id): print("Command \(id) cancelled")
        }
    }
    .store(in: &cancellables)
```

### Processing Device Responses

```swift
handler.processAcknowledgment(transactionID: 123)
handler.processResponse(transactionID: 123, response: "OK")
handler.processError(transactionID: 123, message: "Joint limit exceeded")
```

### Timeout and Transaction ID Resolution

**Transaction ID (`trID`) resolution (priority order):**
1. Command's `trID` if `>= 0`
2. Auto-generated unique ID cycling 1–899 (UR protocol range)

**Timeout resolution (priority order):**
1. Explicit `timeout` parameter in `submit()`
2. Command's `timeout` property
3. Handler's `defaultTimeout` (default: 30s)

```swift
let moveCmd = RobotCommand("moveto",
    arguments: ["1.57", "-1.57", "0.0"],
    timeout: 45.0,
    commandType: .serial
)
handler.submit(moveCmd)                // Uses 45s timeout
handler.submit(moveCmd, timeout: 120.0) // Override to 120s
```

### Resource State Monitoring

```swift
handler.resourceStatePublisher
    .sink { state in print("Resource state: \(state)") }
    .store(in: &cancellables)
```

## Events

| Type | Description | Routing |
|------|-------------|---------|
| **Solicited** | Associated with a transaction | Transaction's `eventPublisher` |
| **Unsolicited** | General device notifications | Handler's `unsolicitedEventPublisher` |

### Unsolicited Events

```swift
handler.unsolicitedEventPublisher
    .sink { event in print("Event code=\(event.code) payload=\(event.payload ?? "")") }
    .store(in: &cancellables)

// Filter for safety events (2000–2999)
handler.unsolicitedEventPublisher
    .filter { $0.code >= 2000 && $0.code < 3000 }
    .sink { event in handleSafetyEvent(event) }
    .store(in: &cancellables)
```

### Solicited Events

```swift
let moveTransaction = handler.submit(moveCmd)

moveTransaction.eventPublisher
    .sink { event in
        switch event.code {
        case 1001: print("Waypoint reached: \(event.payload ?? "")")
        default: break
        }
    }
    .store(in: &cancellables)
```

### Processing Events from the Device

```swift
// Using TransactionEvent struct
let event = TransactionEvent(code: 2001, payload: "collision detected", transactionID: nil)
handler.processEvent(event)

// Convenience overload
handler.processEvent(code: 1001, payload: "waypoint-3", transactionID: 123)
```

## Bidirectional Usage

- **Outbound** (local initiates): call `submit(_:)` and subscribe to the returned `Transaction`
- **Inbound** (remote initiates): assign `inboundTransactionHandler`. When an unknown `trID` arrives, the `messageParser` should route it here instead of silently dropping it.

```swift
handler.inboundTransactionHandler = { handler, message in
    // Parse the remote-initiated frame, then respond via the pipe
}
```

## Communication Pipes

`TransactionHandler` uses `MessageDuplex` (from `FoundationInterfaces`) for transport:

```swift
handler.attachPipe(commandServerSocket)
handler.detachPipe()
handler.hasPipe  // Bool
```

Inbound messages are routed through `messageParser`:

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

## Files (spmFoundationTools/FoundationTransactions)

| File | Description |
|------|-------------|
| `TransactionHandler.swift` | Main handler class |
| `Transaction.swift` | Transaction state and publishers |
| `ResourceState.swift` | Resource state enum |
| `TransactionEvent.swift` | Event type for solicited/unsolicited events |
| `TransactionConcurrency.swift` | Concurrency category enum |
| `TransactionalCommand.swift` | Protocol for commands; includes default `serialize(transactionID:)` |

# TransactionHandler

A composable transaction management system for robot and automation device communication.

## Overview

`TransactionHandler` provides isolated, type-safe transaction handling for devices following the command-acknowledgment-response protocol pattern:

```
cmd → ack → (work) → response
```

Each handler manages a single device resource, allowing multiple handlers to coexist for different devices while maintaining isolation.

## Command Categories

Commands declare their category via the `commandType` property on `TransactionalCommand`:

| Category | Execution | Queueing | Use Case |
|----------|-----------|----------|----------|
| **Motion** | Serial, blocking | Queued | Physical movement commands (home, moveto, jog) |
| **Query** | Parallel | N/A | Read-only status queries (status, currentpose) |
| **Settable** | Serial | Queued | Configuration changes (teach points, calibration) |

## Device States

| State | Description | Command Acceptance |
|-------|-------------|-------------------|
| `disconnected` | No communication established | None |
| `idle` | Ready for commands | All categories |
| `busy` | Executing motion command | Query only |
| `error` | Device error state | None |
| `estop` | Emergency stop active | None |
| `initializing` | Startup routines | Query only |

## Usage

### Basic Setup

```swift
import SwiftRobotics
import OpenCombine

// Create handler for a specific device
let handler = TransactionHandler<RobotCommand>(
    resourceID: "robot-1",
    initialState: .idle
)

// Set up device communication delegate
handler.delegate = myDeviceCommunicator

// Store subscriptions
var cancellables = Set<AnyCancellable>()
```

### Submitting Commands

```swift
// Motion command (default) - queued if busy
let moveTransaction = handler.submit(.home)

// Query command - runs in parallel
let statusCmd = RobotCommand("status", commandType: .query)
let statusTransaction = handler.submit(statusCmd)

// Subscribe to results
moveTransaction.resultPublisher
    .sink { result in
        switch result {
        case .acknowledged(let id):
            print("Command \(id) acknowledged")
        case .completed(let id, let response):
            print("Command \(id) completed: \(response ?? "")")
        case .failed(let id, let error):
            print("Command \(id) failed: \(error)")
        case .queued(let id, let position):
            print("Command \(id) queued at position \(position)")
        case .timedOut(let id):
            print("Command \(id) timed out")
        }
    }
    .store(in: &cancellables)
```

### Processing Device Responses

```swift
// When device acknowledges command
handler.processAcknowledgment(transactionID: 123)

// When device completes command
handler.processResponse(transactionID: 123, response: "OK")

// When device reports error
handler.processError(transactionID: 123, message: "Joint limit exceeded")
```

### Timeout and Transaction ID Resolution

The handler respects values defined on the command itself, allowing timeouts to be tuned based on observed command behavior or historical data.

**Transaction ID (`trID`) resolution:**
1. Command's `trID` if valid (>= 0)
2. Auto-generated unique ID (fallback)

**Timeout resolution:**
1. Explicit `timeout` parameter in `submit()`
2. Command's `timeout` property
3. Handler's `defaultTimeout` (fallback)

```swift
// Command with pre-configured timeout from observed history
let moveCmd = RobotCommand("moveto",
    arguments: ["1.57", "-1.57", "0.0"],
    timeout: 45.0,  // Based on historical execution time
    commandType: .motion
)
handler.submit(moveCmd)  // Uses 45 second timeout

// Override at submission time if needed
handler.submit(moveCmd, timeout: 120.0)  // Explicit override to 120 seconds

// Command with assigned transaction ID for correlation
let trackedCmd = RobotCommand("status",
    trID: 12345,  // Assigned ID for tracking
    commandType: .query
)
let txn = handler.submit(trackedCmd)
print(txn.id)  // 12345
```

### Device State Monitoring

```swift
handler.deviceStatePublisher
    .sink { state in
        print("Device state: \(state)")
    }
    .store(in: &cancellables)
```

## Events

The handler supports both **solicited** and **unsolicited** events from devices.

### Event Types

| Type | Description | Routing |
|------|-------------|---------|
| **Solicited** | Associated with a transaction | Transaction's `eventPublisher` |
| **Unsolicited** | General device notifications | Handler's `unsolicitedEventPublisher` |

### Event Codes

Events carry a user-assignable `code` for filtering and categorization. Define your own scheme or use suggested ranges:

| Range | Suggested Use |
|-------|---------------|
| 1000-1999 | Motion events (progress, waypoints) |
| 2000-2999 | Safety events (collision, estop) |
| 3000-3999 | Status/diagnostic events |
| 4000-4999 | Application-specific events |
| 5000-5999 | Streaming data events |

### Unsolicited Events

Events not tied to any transaction (e.g., robot hit a wall, unexpected state change):

```swift
// Subscribe to all unsolicited events
handler.unsolicitedEventPublisher
    .sink { event in
        print("Device event: code=\(event.code) payload=\(event.payload ?? "")")
    }
    .store(in: &cancellables)

// Filter for safety events only
handler.unsolicitedEventPublisher
    .filter { $0.code >= 2000 && $0.code < 3000 }
    .sink { event in
        handleSafetyEvent(event)
    }
    .store(in: &cancellables)
```

### Solicited Events

Events associated with a specific transaction (e.g., waypoint reached, progress update):

```swift
let moveTransaction = handler.submit(moveCmd)

// Subscribe to events during this transaction
moveTransaction.eventPublisher
    .sink { event in
        switch event.code {
        case 1001: print("Waypoint reached: \(event.payload ?? "")")
        case 1002: print("Progress: \(event.payload ?? "")%")
        default: break
        }
    }
    .store(in: &cancellables)

// Access all events after completion
moveTransaction.resultPublisher
    .sink { _ in
        print("Received \(moveTransaction.events.count) events during execution")
    }
    .store(in: &cancellables)
```

### Processing Incoming Events

Route events from your device communication layer:

```swift
// Using a DeviceEvent struct
let event = DeviceEvent(code: 2001, payload: "collision detected", transactionID: nil)
handler.processEvent(event)

// Using convenience method
handler.processEvent(code: 1001, payload: "waypoint-3", transactionID: 123)
```

## Communication Pipes

The handler supports a pipe-based architecture for integrating with communication layers.

### Pipe Protocols (Foundation Candidates)

| Protocol | Direction | Purpose |
|----------|-----------|---------|
| `TransactableMessageSending` | Outbound | Send messages to device |
| `TransactableMessageReceiving` | Inbound | Assign receive handler |
| `MessagePipe` | Bidirectional | Combined send/receive |
| `TransactionPipe` | Transaction-aware | Specialized for TransactionHandler |

### Attaching a Pipe

TODO - need to fix this section

### Detaching

```swift
handler.detachPipe()
```

## Command Types

Commands specify their category via the `commandType` property:

```swift
// Motion command (blocking, serial execution)
let homeCmd = RobotCommand("home", commandType: .motion)

// Query command (parallel execution)
let statusCmd = RobotCommand("status", commandType: .query)

// Settable command (serial execution)
let teachCmd = RobotCommand("teachPoint", arguments: ["p1"], commandType: .settable)
```

## Resource Identification

Commands carry a `resourceID` to maintain identification as they pass through the system:

```swift
let cmd = RobotCommand("home", resourceID: "robot-1", commandType: .motion)
```

## Files

| File | Description |
|------|-------------|
| `TransactionHandler.swift` | Main handler class |
| `Transaction.swift` | Transaction state tracking |
| `DeviceState.swift` | Device states and errors |
| `DeviceEvent.swift` | Event types for solicited/unsolicited events |
| `MessagePipeProtocol.swift` | Pipe protocols for communication integration |

See also: `Commands/TransactionalCommandCategory.swift` for the category enum.

## Foundation Protocol Candidates

The following protocols in `MessagePipeProtocol.swift` are candidates for extraction to `spmFoundationTools`:

- `TransactableMessageSending` - Outbound message transmission
- `TransactableMessageReceiving` - Inbound handler assignment
- `MessagePipe` - Bidirectional combination

These provide a common base for any component needing bidirectional string-based communication.

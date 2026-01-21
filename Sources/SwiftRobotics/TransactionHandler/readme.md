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

## Implementing the Delegate

```swift
class DeviceCommunicator: TransactionHandlerDelegate {
    func transactionHandler<Command: TransactionalCommand>(
        _ handler: TransactionHandler<Command>,
        sendCommand command: String,
        transactionID: Int
    ) {
        // Send command via socket/serial/etc.
        socket.send(command)
    }
}
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

See also: `Commands/TransactionalCommandCategory.swift` for the category enum.

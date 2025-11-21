# SwiftRoboticsSockets Test Suite

Comprehensive test suite for SwiftRoboticsSockets with Docker-based URSim simulation.

## Overview

This test suite validates all four socket interfaces for Universal Robot communication:
1. **Dashboard Socket** (Port 29999) - High-level robot control
2. **URScript Socket** (Port 30001) - URScript program loading
3. **Command/Control Socket** (Port 50001) - Transaction-based command execution
4. **Streaming Socket** (Port 50002) - High-frequency motion streaming

## Prerequisites

### Required Software
- macOS 14.0 or later
- Swift 6.1 or later
- Docker Desktop for Mac
- Universal Robots URSim Docker image

### Docker Setup

Start the URSim container with all required ports:

```bash
docker run --rm -it \
  -p 5900:5900 \
  -p 6080:6080 \
  -p 29999:29999 \
  -p 30001:30001 \
  -p 30004:30004 \
  -p 50001:50001 \
  -p 50002:50002 \
  -v ~/Documents/programs:/ursim/programs \
  --platform=linux/amd64 \
  universalrobots/ursim_e-series
```

**Port Mapping:**
- `5900` - VNC server
- `6080` - noVNC web interface (http://localhost:6080)
- `29999` - Dashboard server
- `30001` - Primary interface (URScript)
- `30004` - Real-time data exchange (RTDE)
- `50001` - Command/Control server (custom)
- `50002` - Streaming server (custom)

## Test Structure

```
Tests/SwiftRoboticsSocketsTests/
├── Infrastructure/
│   ├── URScriptTemplateManager.swift    # URScript template and IP replacement
│   ├── NetworkUtilities.swift           # Network helpers (IP detection, ports)
│   ├── TestConfiguration.swift          # Test configuration and timeouts
│   └── TestHelpers.swift                # Async utilities and assertions
│
├── Integration/
│   ├── DashboardSocketTests.swift       # Scenario 1: Dashboard tests
│   ├── URScriptSocketTests.swift        # Scenario 2: URScript loading tests
│   ├── CommandControlSocketTests.swift  # Scenario 3: Command/Control tests
│   └── StreamingSocketTests.swift       # Scenario 4: Streaming tests
│
└── README.md                             # This file
```

## Configuration

### Host IP Address

The test suite auto-detects your local IP address for robot callbacks. You can override this in `TestConfiguration.swift`:

```swift
public static var hostCallbackIP: String {
    return "192.168.1.100"  // Manual override
    // or auto-detect:
    return (try? NetworkUtilities.getLocalIPAddress()) ?? "192.168.1.100"
}
```

### Robot IP Address

By default, tests connect to `localhost` (Docker with port forwarding). Change in `TestConfiguration.swift`:

```swift
public static let robotIP: String = "localhost"  // or "192.168.1.50"
```

### Timeouts

Adjust timeouts in `TestConfiguration.swift`:

```swift
public static let connectionTimeout: TimeInterval = 10.0
public static let commandTimeout: TimeInterval = 5.0
public static let streamingTimeout: TimeInterval = 30.0
public static let movementTimeout: TimeInterval = 15.0
```

## Running Tests

### All Tests

```bash
swift test
```

### Specific Test Suite

```bash
# Dashboard tests only
swift test --filter DashboardSocketTests

# URScript tests only
swift test --filter URScriptSocketTests

# Command/Control tests only
swift test --filter CommandControlSocketTests

# Streaming tests only
swift test --filter StreamingSocketTests
```

### Specific Test

```bash
swift test --filter testDashboardConnection
swift test --filter testCompleteStreamingFlow
```

## Test Scenarios

### Scenario 1: Dashboard Socket Tests

Tests basic dashboard communication:
- Connection establishment
- Robot mode queries
- Power on/off commands
- Brake release
- Program control (play, stop, pause)
- Sequential command execution
- Connection state transitions

**Run:**
```bash
swift test --filter DashboardSocketTests
```

### Scenario 2: URScript Socket Tests

Tests URScript loading and IP replacement:
- Template loading with placeholder
- Host IP replacement
- Auto IP detection
- Script preparation for testing
- URScript transmission to robot
- Multiple script sends
- Script content validation

**Key Feature:** Tests the `<<HOST_CALLBACK_IPADDRESS>>` placeholder replacement.

**Run:**
```bash
swift test --filter URScriptSocketTests
```

### Scenario 3: Command/Control Socket Tests

Tests command server and callback communication:
- Command server startup
- Robot callback connection after URScript
- `initRobot` command
- `home` command
- `status` command
- `ver` command
- `currentpose` command
- `currentposture` command
- Sequential command execution
- Transaction ID management

**Note:** These tests require URScript to be loaded first (Scenario 2) to establish the callback.

**Run:**
```bash
swift test --filter CommandControlSocketTests
```

### Scenario 4: Streaming Socket Tests

Tests motion streaming functionality:
- Streaming server startup
- Waveform loading from `streamRotateBase.json`
- Batch dequeuing (URScript format)
- Streaming progress tracking
- Complete streaming flow with robot
- `startstreaming` / `stopstreaming` commands
- Waveform reset and re-streaming
- Multiple waveform loading

**Run:**
```bash
swift test --filter StreamingSocketTests
```

## URScript Template System

### Placeholder Format

The URScript template (`Sources/SwiftRoboticAssets/Assets/UR/urScript.script`) uses a placeholder for the host IP:

```urscript
global con = struct(host_ip = "<<HOST_CALLBACK_IPADDRESS>>", ...)
```

### Runtime Replacement

Before sending to the robot, the placeholder is replaced with the actual host IP:

```swift
let script = try URScriptTemplateManager.prepareScriptForTest()
// Replaces <<HOST_CALLBACK_IPADDRESS>> with auto-detected IP

let script = try URScriptTemplateManager.prepareScriptForTest(hostIP: "192.168.1.100")
// Replaces with manual IP
```

### Verification

```swift
let template = try URScriptTemplateManager.loadTemplate()
assert(template.contains("<<HOST_CALLBACK_IPADDRESS>>"))

let prepared = URScriptTemplateManager.replaceHostIP(in: template, with: "192.168.1.100")
assert(!prepared.contains("<<HOST_CALLBACK_IPADDRESS>>"))
assert(URScriptTemplateManager.isScriptPrepared(prepared))
```

## Complete Integration Test Flow

To test the complete workflow (all 4 scenarios):

1. **Start URSim** (with ports 50001, 50002 exposed)
2. **Dashboard Connection** - Verify robot is accessible
3. **Send URScript** - Load script with host IP replacement
4. **Wait for Callbacks** - Robot connects to ports 50001, 50002
5. **Command Execution** - Send init, home, status commands
6. **Load Waveform** - Load streamRotateBase.json
7. **Start Streaming** - Execute streaming motion
8. **Monitor Progress** - Track streaming completion
9. **Stop Streaming** - Clean shutdown

**Run the complete flow:**
```bash
swift test --filter testCompleteCommandFlow
swift test --filter testCompleteStreamingFlow
```

## Troubleshooting

### Connection Timeouts

If tests timeout waiting for connections:
1. Verify URSim is running: `docker ps`
2. Check ports are exposed: `docker port <container_id>`
3. Verify robot is powered on in URSim GUI (http://localhost:6080)
4. Check firewall isn't blocking ports 50001, 50002

### Callback Not Establishing

If robot doesn't connect back to command/streaming servers:
1. Verify host IP is correct: `swift test --filter testAutoIPDetection`
2. Check URScript was sent: `swift test --filter testLoadAndSendURScript`
3. View URSim program log for connection errors
4. Ensure ports 50001, 50002 are available: `lsof -i :50001`

### Streaming Doesn't Start

If streaming tests fail:
1. Ensure command connection is established first
2. Send `initRobot` before `startstreaming`
3. Verify waveform loaded: Check `hasMoreData` property
4. Check URSim program is running (not stopped)

### IP Detection Fails

If auto IP detection returns wrong address:
1. Manually set IP in `TestConfiguration.hostCallbackIP`
2. Run `ifconfig` to find correct network interface
3. Ensure you're on same network as robot (if using real hardware)

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3
      - name: Start URSim
        run: |
          docker pull universalrobots/ursim_e-series
          docker run -d -p 29999:29999 -p 30001:30001 -p 50001:50001 -p 50002:50002 \
            --platform=linux/amd64 universalrobots/ursim_e-series
          sleep 30  # Wait for URSim to start
      - name: Run Tests
        run: swift test
```

## Best Practices

### Test Isolation
- Each test creates fresh handler instances
- Servers are properly stopped after tests
- No shared mutable state between tests

### Timeouts
- All async operations have timeouts
- Configurable per operation type
- Fail fast with clear error messages

### Cleanup
- Temporary files are removed
- Sockets are disconnected
- Cancellables are cancelled
- Servers are shut down

### Assertions
- Clear expectation messages
- Detailed logging output
- Progress monitoring for long operations

## Contributing

When adding new tests:
1. Follow existing test structure
2. Use `TestHelpers` for async operations
3. Add clear print statements for debugging
4. Include timeout handling
5. Clean up resources in test
6. Update this README

## License

Same as parent project (SwiftRobotics)

## Support

For issues or questions:
- Check URSim documentation: https://www.universal-robots.com/download/
- Review test output for detailed error messages
- Verify Docker and network configuration

# Workflow

## Building

```bash
# macOS development
swift build

# Linux / Jetson — same command
swift build

# Release build (optimized, use on Jetson)
swift build -c release
```

## Testing

> **Blocker:** `swift test` (full package) currently fails because `spmSocketHandlers` `dev` branch has 5 Swift 6 strict-concurrency errors in `NIOHandlerServer.swift`. Use the targeted commands below.

```bash
# Core kinematics + command tests (always works)
swift test --filter SwiftRoboticsTests

# Socket integration tests (requires URSim via Docker)
# See Sources/SwiftRoboticsSockets/UniversalRobot/readme.md for Docker setup
swift test --filter SwiftRoboticsSocketsTests

# Parallel testing (useful on multi-core Jetson)
swift test --filter SwiftRoboticsTests --parallel
```

## Formatting

The project uses `swift-format`. Config: `.swift-format`.

```bash
swift-format -i -r Sources/ Tests/
```

## Cross-Platform Testing

### Linux via Docker

```bash
docker run --rm -v "$PWD:/workspace" -w /workspace swift:6.1 swift test
```

### Jetson (on device)

```bash
ssh jetson-device 'cd /path/to/project && swift test'
```

## New Feature Checklist

- [ ] Compiles on macOS
- [ ] Compiles on Linux x86_64
- [ ] Tests pass on macOS
- [ ] Tests pass on Linux
- [ ] No platform-specific APIs used
- [ ] SIMD operations validated on ARM64
- [ ] Verified on Jetson hardware (performance-critical features)

## URSim Docker (Socket Integration Testing)

```bash
docker run --rm -it \
  -p 5900:5900 \
  -p 6080:6080 \
  -p 29999:29999 \
  -p 30001:30001 \
  -p 30004:30004 \
  -p 50001:50001 \
  -p 50002:50002 \
  -v <path-to-programs-dir>:/ursim/programs \
  --platform=linux/amd64 \
  universalrobots/ursim_e-series
```

Access at `http://localhost:6080` (web) or `localhost:5900` (VNC).

## Linux System Dependencies

```bash
# Debian/Ubuntu — clang required for SwiftNIO
sudo apt install clang

# GTK-4 if building visualization targets
sudo apt install libgtk-4-dev pkg-config
```

## Jetson Prerequisites

- JetPack SDK 4.6+ or 5.0+
- Swift for ARM64 (aarch64)
- 4GB+ RAM recommended for compilation

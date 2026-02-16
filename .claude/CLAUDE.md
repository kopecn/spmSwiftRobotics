# SwiftRobotics Project Specification

## Overview

SwiftRobotics is a Swift library for robotic manipulator kinematics, dynamics, and visualization. The library focuses on serial manipulators and provides tools for forward kinematics, inverse kinematics, pose/posture calculations, and 3D visualization.

## Architecture

### Core Components

#### SwiftRobotics (Library)
The main library providing robotics functionality:

- **Kinematics**: Forward/inverse kinematics, pose and posture representations
  - `KinematicLinkProtocol`: Protocol for kinematic chain links
  - `KinematicLinkDH`: Denavit-Hartenberg parameter-based kinematic links
  - `PoseRobot`, `PostureSerialRobot`: Robot pose/posture representations
  - `PoseWaveform`, `PostureSerialRobotWaveform`: Time-based trajectories

- **Manipulator**: Robot manipulator models and implementations
  - `ManipulatorProtocol`: Protocol for manipulator implementations
  - `ManipulatorSerial`: Serial manipulator implementation
  - Specific robot implementations (e.g., Universal Robots UR series)
    - for Universal Robot urScript development refer to API in `.claude/CLAUDE.md`

- **Support**: Utility types and extensions
  - `RobotRenderingAssetType`: Asset management for 3D rendering
  - SIMD extensions for homogeneous transforms

#### SwiftRoboticAssets (Target)
Asset management for robot visualization resources.

## Dependencies

**All dependencies must be compatible with Linux and ARM64 (Jetson) platforms.**

- **kvSIMD**: SIMD vector/matrix operations for kinematics calculations
  - ✅ Cross-platform: macOS, Linux, ARM64
  - Architecture-aware SIMD optimizations

- **SwiftCrossUI**: Cross-platform UI framework for visualization
  - ✅ Supports: macOS (AppKit), Linux (GTK-4)
  - GTK backend enables visualization on Jetson devices

- **swift-argument-parser**: Command-line interface tools
  - ✅ Pure Swift, fully cross-platform

- **depermaid**: Dependency visualization
  - ⚠️ Verify Linux compatibility before use

### Dependency Review Process
When adding new dependencies:
1. Verify Linux/ARM64 support in package documentation
2. Test build on Linux environment (Docker or native)
3. Confirm no platform-specific APIs (Darwin-only frameworks)
4. Check for C library dependencies and their Jetson availability
5. Test on actual Jetson hardware if introducing performance-critical dependencies

## Platform Requirements

**All packages must be compatible with Linux and NVIDIA Jetson platforms.**

### Supported Platforms
- **macOS**: 14.0+ (development and testing)
- **Linux**: Ubuntu 20.04+, Debian-based distributions
- **NVIDIA Jetson**: Jetson Nano, TX2, Xavier NX, AGX Xavier, Orin series
- **Swift**: 6.1+ (ensure compatibility across all platforms)

### Platform-Specific Requirements

#### Linux (General)
- GTK-4 development libraries for SwiftCrossUI visualizer:
  ```bash
  # Debian/Ubuntu
  sudo apt install libgtk-4-dev clang

  # Fedora
  sudo dnf install gtk4-devel clang
  ```

#### NVIDIA Jetson
- JetPack SDK 4.6+ or 5.0+ (depending on Jetson model)
- CUDA Toolkit (included in JetPack)
- GTK-4 libraries:
  ```bash
  sudo apt update
  sudo apt install libgtk-4-dev clang pkg-config
  ```
- Swift for ARM64 (aarch64) architecture
- Recommended: 4GB+ RAM for compilation

### Cross-Platform Compatibility Guidelines
- Use only cross-platform Swift standard library APIs
- Avoid platform-specific Foundation APIs where possible
- Test on both x86_64 and ARM64 architectures
- Ensure SIMD operations are architecture-agnostic
- SwiftCrossUI backends: GTK for Linux/Jetson, AppKit for macOS

## Code Conventions

### Naming
- Types: PascalCase (e.g., `KinematicLinkDH`, `ManipulatorSerial`)
- Properties/Methods: camelCase (e.g., `getPose`, `centerOfMass`)
- Protocols: PascalCase with "Protocol" suffix (e.g., `KinematicLinkProtocol`, `ManipulatorProtocol`)

### File Organization
```
Sources/
├── SwiftRobotics/
│   ├── Kinematics/          # Forward/inverse kinematics
│   ├── Manipulator/         # Robot manipulator models
│   │   └── SpecificManipulators/  # Vendor-specific implementations
│   ├── Support/             # Utilities and asset types
│   └── Extensions/          # Standard library extensions
└── SwiftRoboticAssets/      # 3D assets and resources
```

### Denavit-Hartenberg Convention
The library uses standard DH parameters for kinematic chains:
- `a`: Link length (distance along x-axis)
- `alpha`: Link twist (rotation around x-axis in radians)
- `d`: Link offset (distance along z-axis)
- `theta`: Joint angle (rotation around z-axis in radians)

### Transform Representation
- DH transform construction available via SIMD extensions

## Key Features

1. **Forward Kinematics**: Compute end-effector pose from joint angles
2. **Inverse Kinematics**: Solve for joint angles from desired pose
3. **Trajectory Planning**: Waveform-based motion planning
4. **3D Visualization**: Cross-platform robot visualization (macOS, Linux, Jetson)
5. **Modular Design**: Protocol-based architecture for extensibility
6. **Embedded-Ready**: Optimized for deployment on NVIDIA Jetson platforms
7. **Cross-Platform**: Single codebase runs on macOS, Linux, and ARM64 embedded systems

## Development Workflow

### Building

#### macOS
```bash
swift build
```

#### Linux / Jetson
```bash
# Standard build
swift build

# Release build (optimized for embedded systems)
swift build -c release

# With verbose output for debugging
swift build -v
```

### Testing

#### All Platforms
```bash
swift test
```

#### Platform-Specific Tests
```bash
# Run specific test suite
swift test --filter SwiftRoboticsTests

# Parallel testing (useful on multi-core Jetson devices)
swift test --parallel
```

### Cross-Compilation Considerations

When developing on macOS for Linux/Jetson deployment:
- Test on actual target hardware regularly
- Consider ARM64 architecture differences in SIMD operations
- Profile performance on target Jetson hardware

### Formatting
The project uses `swift-format` for code formatting. Configuration should be in `.swift-format`.

```bash
# Format all Swift files
swift-format -i -r Sources/ Tests/
```

### Cross-Platform Testing Strategy

#### Local Testing
```bash
# macOS development
swift test

# Linux testing via Docker
docker run --rm -v "$PWD:/workspace" -w /workspace swift:6.1 swift test

# Jetson testing (on device)
ssh jetson-device 'cd /path/to/project && swift test'
```

#### Continuous Integration
Consider setting up CI pipelines that test on:
- macOS (x86_64/ARM64)
- Linux (x86_64) via Docker
- Linux (ARM64) via cross-compilation or native build

#### Testing Checklist for New Features
- [ ] Compiles on macOS
- [ ] Compiles on Linux x86_64
- [ ] Tests pass on macOS
- [ ] Tests pass on Linux
- [ ] No platform-specific APIs used
- [ ] Verified on Jetson hardware (for performance-critical features)
- [ ] SIMD operations validated on ARM64

## Extension Points

To add a new robot manipulator:
1. Create a new file in `Sources/SwiftRobotics/Manipulator/SpecificManipulators/<Vendor>/`
2. Implement `ManipulatorProtocol`
3. Define kinematic links using `KinematicLinkDH`
4. Implement forward kinematics via `ManipulatorSerial`
5. Optionally implement inverse kinematics (see `ManipulatorUR+IK.swift`)

## Deployment


### Package Configuration

Ensure `Package.swift` is configured for cross-platform compatibility:
```swift
platforms: [
    .macOS(.v14),
    .linux,  // Supports all Linux distributions including Jetson
]
```

**Important**: Do not use iOS-specific, watchOS, or tvOS APIs. All dependencies must support Linux.

## Common Tasks

- **Add new kinematic link type**: Conform to `KinematicLinkProtocol`
- **Add new manipulator**: Conform to `ManipulatorProtocol`
- **Add 3D assets**: Place in `SwiftRoboticAssets` target
- **Test cross-platform**: Verify on both macOS and Linux before committing
- **Performance profiling**: Test on target Jetson hardware for real-world performance

## Recommended Fixes

### High Priority

- [ ] **1. Resolve TODO/FIXME in socket handlers**
  - `URRobotCommandMessageHandling.swift` — FIXME: "Add appropriate handler for transaction management"
  - `URRobotCommandHandler+commands.swift` — TODO: "Implement proper transaction ID management (increment, wrap at 899)"

- [ ] **2. Add unit tests for core modules**
  - `SwiftRoboticsTests.swift` is a template — needs real tests
  - Missing coverage: `ManipulatorSerial`, `KinematicLinkDH`, `WaveformStreamer`, `RobotCommand` serialization, `AssetLoader`

- [ ] **3. Adopt conventional commit messages**
  - Use `feat:`, `fix:`, `refactor:` prefixes
  - Avoid vague messages like `"neat..."` or `"continued work."`

### Medium Priority

- [ ] **4. Improve socket error recovery**
  - Swift-side handlers need reconnection/retry strategies for command (50001) and streaming (50002) sockets

- [ ] **5. Evaluate Swift Concurrency migration**
  - Current: OpenCombine + GCD
  - Consider `async/await` + `AsyncSequence` for streaming/transaction pipelines
  - OpenCombine still needed if targeting Linux/Jetson

- [ ] **6. Document `WaveformStreamer` thread safety**
  - Struct with mutating methods — clarify ownership model or add synchronization

- [ ] **7. Centralize network constants**
  - Ports (50001, 50002, 30001, 29999) and buffer sizes (250) are scattered across files
  - Create a configuration type

### Low Priority

- [ ] **8. Expose forward kinematics API**
  - IK solver exists but FK isn't publicly exposed — useful for pose verification

- [ ] **9. Fill in documentation gaps**
  - `SwiftRoboticAssets/Assets/UR/readme.md` is a placeholder
  - Top-level `readme.md` needs a getting-started guide with code examples

- [ ] **10. Enforce swift-format in CI**
  - Confirm formatting is checked automatically to prevent style drift

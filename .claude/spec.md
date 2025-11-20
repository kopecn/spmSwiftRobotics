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
    - for Universal Robot urScript development refer to API in .md located in `.claude/spec.md`

- **Support**: Utility types and extensions
  - `RobotRenderingAssetType`: Asset management for 3D rendering
  - SIMD extensions for homogeneous transforms

#### SwiftRoboticVisualizer (Executable)
A cross-platform visualizer for robot manipulators using SwiftCrossUI.
- **macOS**: Uses AppKit backend (native)
- **Linux/Jetson**: Uses GTK-4 backend
- Designed to run on embedded systems with minimal resource overhead

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
├── SwiftRoboticVisualizer/  # Visualization app
└── SwiftRoboticAssets/      # 3D assets and resources
```

### Denavit-Hartenberg Convention
The library uses standard DH parameters for kinematic chains:
- `a`: Link length (distance along x-axis)
- `alpha`: Link twist (rotation around x-axis in radians)
- `d`: Link offset (distance along z-axis)
- `theta`: Joint angle (rotation around z-axis in radians)

### Transform Representation
- Homogeneous transforms: `simd_double4x4`
- Custom extensions in `Extensions/simd_double4x4.swift`
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

### Running Visualizer

#### macOS
```bash
swift run SwiftRoboticVisualizer
```

#### Linux / Jetson
```bash
# Ensure DISPLAY is set for GUI
export DISPLAY=:0
swift run SwiftRoboticVisualizer

# For headless testing (if implementing headless mode)
swift run SwiftRoboticVisualizer --headless
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

### Jetson Deployment

#### Preparing the Executable
```bash
# Build release binary on Jetson or cross-compile
swift build -c release

# Binary location
.build/release/SwiftRoboticVisualizer
```

#### Installing Swift on Jetson
```bash
# Download Swift for ARM64
wget https://download.swift.org/swift-6.1-release/ubuntu2004-aarch64/swift-6.1-RELEASE/swift-6.1-RELEASE-ubuntu20.04-aarch64.tar.gz

# Extract and install
tar xzf swift-6.1-RELEASE-ubuntu20.04-aarch64.tar.gz
sudo mv swift-6.1-RELEASE-ubuntu20.04-aarch64 /opt/swift
echo 'export PATH=/opt/swift/usr/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

#### Performance Optimization for Embedded Systems
- Use release builds (`-c release`) for production
- Consider `-Xswiftc -O` for additional optimizations
- Profile memory usage on resource-constrained Jetson devices
- Implement lazy loading for 3D assets
- Use SIMD optimizations (kvSIMD is architecture-aware)

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
- **Extend visualizer**: Modify `SwiftRoboticVisualizer/macOS/ContentView.swift` (ensure changes work on Linux/GTK backend)
- **Add 3D assets**: Place in `SwiftRoboticAssets` target
- **Test cross-platform**: Verify on both macOS and Linux before committing
- **Performance profiling**: Test on target Jetson hardware for real-world performance

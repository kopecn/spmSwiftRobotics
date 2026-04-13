# SwiftRobotics

Swift library for robotic manipulator kinematics, trajectory planning, and UR robot communication. Targets macOS 14+, Linux, and NVIDIA Jetson (ARM64). Swift 6.1+.

## Quick Commands

```bash
# Build
swift build

# Test (core — always works)
swift test --filter SwiftRoboticsTests

# Test (full package — blocked, see blocker below)
swift test

# Format
swift-format -i -r Sources/ Tests/
```

## Active Blocker

`swift test` (full package) fails: `spmSocketHandlers` `dev` branch has 5 Swift 6 Sendable errors in `NIOHandlerServer.swift`. Fix: `let keyStr = "\(key)"` before each `AnyHashable` capture. See [`specs/fixes.md`](.claude/specs/fixes.md).

## Subspecs

| Topic | File | When to read |
|-------|------|-------------|
| Targets, file tree, key types | [`specs/architecture.md`](.claude/specs/architecture.md) | Navigating the codebase, adding types |
| FK, IK, DH, WaveformStreamer | [`specs/kinematics.md`](.claude/specs/kinematics.md) | Kinematics work, adding manipulators |
| 4 UR socket handlers, protocol | [`specs/sockets.md`](.claude/specs/sockets.md) | Socket/networking work |
| Naming, DH, transforms, OpenCombine | [`specs/conventions.md`](.claude/specs/conventions.md) | Code style, new files |
| Build, test, format, CI, Docker | [`specs/workflow.md`](.claude/specs/workflow.md) | Build/test/deploy questions |
| All deps, compat, add-dep process | [`specs/dependencies.md`](.claude/specs/dependencies.md) | Adding or auditing dependencies |
| Open backlog + completed items | [`specs/fixes.md`](.claude/specs/fixes.md) | Picking up work, checking status |

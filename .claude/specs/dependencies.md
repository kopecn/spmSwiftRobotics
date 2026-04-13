# Dependencies

**All dependencies must be compatible with Linux and ARM64 (Jetson) platforms.**

## Current Dependencies

| Package | Products Used | Status | Notes |
|---------|--------------|--------|-------|
| **spmFoundationTools** (private) | `FoundationTools`, `FoundationCommon`, `FoundationTypes`, `FoundationInterfaces`, `FoundationTransactions` | ✅ Cross-platform | `FoundationTransactions` contains `TransactionHandler`, `Transaction`, `ResourceState`, `TransactionEvent`, `TransactionConcurrency`, `TransactionalCommand` |
| **spmMathTools** (private) | Math utilities | ✅ Cross-platform | Used for kinematics calculations |
| **spmSocketHandlers** (private) | `NIOHandler` | ⚠️ Blocker | `dev` branch: 5 Swift 6 Sendable errors in `NIOHandlerServer.swift` — `AnyHashable` captures in `@Sendable` closures at lines ~542, 615, 617, 672, 674. Quick fix: `let keyStr = "\(key)"` before capture. Blocks `swift test` full package. |
| **kvSIMD** | SIMD math | ✅ Cross-platform | Architecture-aware SIMD; macOS, Linux, ARM64 |
| **OpenCombine** | Reactive publishers | ✅ Cross-platform | Replaces Apple Combine for Linux/Jetson |
| **swift-log** | Structured logging | ✅ Cross-platform | |
| **depermaid** | Dependency visualization | ⚠️ Verify | Confirm Linux compatibility before use |

## Adding New Dependencies

1. Verify Linux/ARM64 support in package documentation
2. Confirm no Darwin-only APIs (no `import Darwin`, no Apple-exclusive Foundation APIs)
3. Check for C library dependencies and Jetson availability
4. Test build on Linux: `docker run --rm -v "$PWD:/workspace" -w /workspace swift:6.1 swift build`
5. Test on actual Jetson hardware if the dep is performance-critical
6. Add to `Package.swift` with the appropriate target dependency

## Platform Requirements

| Platform | Version |
|----------|---------|
| macOS | 14.0+ |
| Linux | Ubuntu 20.04+, Debian-based |
| Jetson | JetPack 4.6+ or 5.0+ |
| Swift | 6.1+ |

## Package.swift Notes

- `platforms: [.macOS(.v14)]` — Linux is implied (no explicit `.linux` platform specifier needed in SPM)
- Do **not** add iOS/watchOS/tvOS platform entries
- When a type from an upstream module isn't resolvable in a downstream target, add the upstream product as a **direct** dependency of that target (not just a transitive one)
  - Example: `FoundationTransactions` must be a direct dep of `SwiftRoboticsSockets` because `ResourceState` is used directly in handler files

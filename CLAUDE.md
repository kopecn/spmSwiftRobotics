# SwiftRobotics - CLAUDE.md

## Build & Test

- `make build` — Release build
- `make test` — Run all tests
- `make test-ur` — Run with URSim enabled (requires Docker)
- `make format` — Run swift-format
- Swift 6.1 minimum, macOS 14+

## Code Style

- swift-format with 120-char line length
- Protocol-driven design — prefer protocols over concrete types
- Value types (structs) for high-frequency code paths (e.g., IK solver)
- camelCase for functions/variables, PascalCase for types

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

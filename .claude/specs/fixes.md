# Fixes & Backlog

## Open — High Priority

### 1. Fix spmSocketHandlers Swift 6 Sendable errors
- **Repo:** `kopecn/spmSocketHandlers` (private), `dev` branch
- **File:** `NIOHandlerServer.swift` — 5 errors at lines ~542, 615, 617, 672, 674
- **Root cause:** `AnyHashable` key captured in `@Sendable` closure
- **Fix:** `let keyStr = "\(key)"` before each capture site; use `keyStr` inside the closure
- **Impact:** Blocks `swift test` for the full package. Workaround: `swift test --filter SwiftRoboticsTests`

### 2. Add auto-reconnect to socket handlers
- **Files:** `URRobotDashboardHandler.swift`, `URRobotScriptHandler.swift`, `URRobotCommandHandler.swift`, `URRobotStreamHandler.swift`
- **Issue:** Error state requires manual `toggleConnection()`. No retry or backoff.
- **Plan:** Subscribe to `connectionState`; on `.error`, schedule exponential backoff retry (1s, 2s, 4s, 8s max)
- **Blocked by:** Item 1 — can't fully test socket behavior without the complete test suite

## Open — Medium Priority

### 3. Evaluate Swift Concurrency migration
- Current: OpenCombine + GCD throughout
- Consider `async/await` + `AsyncSequence` for streaming and transaction pipelines
- OpenCombine still required if targeting Linux/Jetson (no native Combine support)
- Evaluate per-subsystem — some areas may be ready before others

### 4. Document WaveformStreamer thread safety
- `WaveformStreamer<W>` is a `struct` with `mutating` methods
- Clarify ownership model: single owner, copy-on-mutate, or add synchronization
- Add a comment at the struct declaration

## Open — Low Priority

### 5. Enforce swift-format in CI
- `swift-format` is used manually but not enforced automatically
- Add a CI step that runs `swift-format --lint -r Sources/ Tests/` and fails on diff

### 6. Add KinematicLinkDH unit tests
- `KinematicLinkDH.getPose(theta:)` is pure DH transform math — no hardware needed
- Validate against known DH table values (e.g., UR5 zero-configuration pose)
- `ManipulatorSerial` and `AssetLoader` also lack direct test coverage

### 7. Adopt conventional commit messages
- Ongoing process discipline
- Use `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:` prefixes
- See `specs/conventions.md` for full guide

## Completed ✅

- ✅ Transaction ID management (wrap at 899) — now in `FoundationTransactions/TransactionHandler.swift`
- ✅ `URProtocolMessageParser` extracted to standalone testable type (`URProtocolMessageParser.swift`)
- ✅ `WaveformStreamer` unit tests added (`WaveformStreamerTests.swift`)
- ✅ `RobotCommand` serialization tests added (`RobotCommandTests.swift`)
- ✅ `URProtocolMessageParser` tests added (`URProtocolMessageParserTests.swift`)
- ✅ Forward kinematics exposed on `ManipulatorProtocol` (default implementation via DH chain)
- ✅ Inverse kinematics typed error context — `IKResult` enum with `.success`, `.outOfWorkspace`, `.singular`, `.noSolution`
- ✅ Network constants centralized in `URNetworkConfiguration` (ports 50001, 50002, 30001, 29999)
- ✅ `ManipulatorSerial` and all `ManipulatorUR*` classes made `public`
- ✅ Root `readme.md` getting-started guide with FK/IK/command examples
- ✅ `TransactionHandler` and related types moved to `FoundationTransactions` in `spmFoundationTools`
- ✅ `TransactionHandler` bidirectionality — `inboundTransactionHandler` for remote-initiated transactions
- ✅ Documentation sync — `TransactionHandler/readme.md`, `UniversalRobot/readme.md`, `CLAUDE.md`, `commands/*.md` all updated to match current API

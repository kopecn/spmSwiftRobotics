Run tests in the SwiftRobotics package and report results including any failures or errors.

**Important:** `swift test` (full package) currently fails because `spmSocketHandlers` `dev` branch has Swift 6 strict-concurrency errors in `NIOHandlerServer.swift`. Use the targeted approach below:

```bash
# Core kinematics + command tests (always works)
swift test --filter SwiftRoboticsTests

# Socket integration tests (requires URSim via Docker)
# See Sources/SwiftRoboticsSockets/UniversalRobot/readme.md for Docker setup
swift test --filter SwiftRoboticsSocketsTests
```

Report:
- Pass/fail count per test suite
- Any assertion failures with expected vs actual values
- Whether the spmSocketHandlers blocker is still present (if running full `swift test`)

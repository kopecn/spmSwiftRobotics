# Architecture

## Targets

| Target | Type | Purpose |
|--------|------|---------|
| `SwiftRobotics` | Library | Core kinematics, manipulator models, commands, trajectory |
| `SwiftRoboticAssets` | Target | Asset loader + UR visualization assets |
| `SwiftRoboticsSockets` | Library | Network communication layer for UR robots |

## File Tree

```
Sources/
├── SwiftRobotics/
│   ├── Commands/                     # RobotCommand + TransactionalCommand conformances
│   ├── Kinematics/                   # Pose/posture types, KinematicLinkDH
│   ├── Manipulator/                  # ManipulatorProtocol, ManipulatorSerial
│   │   └── SpecificManipulators/UR/  # UR robot models, IKResult, URInverseKinematics
│   ├── Support/                      # RobotRenderingAssetType
│   ├── Trajectory/                   # WaveformStreamer, StreamWaveformProtocol
│   └── TransactionHandler/           # readme.md only (types moved to FoundationTransactions)
├── SwiftRoboticAssets/               # AssetLoader + UR assets (urScript.script, waveform JSON)
└── SwiftRoboticsSockets/
    ├── Support/                      # URNetworkConfiguration (port constants)
    └── UniversalRobot/               # 4 socket handlers for UR robot interfaces
        ├── URRobotCommand/
        ├── URRobotDashboard/
        ├── URRobotScript/
        └── URRobotStream/
```

## Key Types by Module

### SwiftRobotics — Kinematics

| Type | Role |
|------|------|
| `KinematicLinkProtocol` | Protocol for kinematic chain links |
| `KinematicLinkDH` | Denavit-Hartenberg parameter link; `getPose(theta:) -> SpatialPose<Float>` |
| `PoseRobot` | End-effector pose (position + orientation) |
| `PostureSerialRobot` | Joint-angle vector for a serial manipulator |

### SwiftRobotics — Manipulator

| Type | Role |
|------|------|
| `ManipulatorProtocol` | Protocol; includes default `forwardKinematics(posture:) -> PoseRobot` |
| `ManipulatorSerial` | Base class for serial manipulators |
| `ManipulatorUR` … `ManipulatorUR30` | 12 UR-series robot models |
| `URInverseKinematics` | Analytical closed-form IK solver (8 configurations) |
| `IKResult` | Typed IK result: `.success([PostureSerialRobot])`, `.outOfWorkspace`, `.singular`, `.noSolution` |
| `URRobotPostureType` | Enum for shoulder/elbow/wrist configuration |

### SwiftRobotics — Commands

| Type | Role |
|------|------|
| `RobotCommand` | Generic, extensible robot command conforming to `TransactionalCommand` |

### SwiftRobotics — Trajectory

| Type | Role |
|------|------|
| `WaveformStreamer<W>` | Generic iterator; batch-dequeues joint positions from a waveform |
| `StreamWaveformProtocol` | Protocol for sample-indexed joint data sources |

### SwiftRoboticsSockets

| Type | Role |
|------|------|
| `URNetworkConfiguration` | Centralized port/protocol constants (50001, 50002, 30001, 29999, maxTransactionID=899) |
| `URRobotCommandHandler` | Reverse-socket command server (port 50001) |
| `URRobotStreamHandler` | Reverse-socket stream server (port 50002) |
| `URRobotDashboardHandler` | Client to robot dashboard (port 29999) |
| `URRobotScriptHandler` | Client to robot primary interface (port 30001) |
| `URProtocolMessageParser` | Parses UR `<trID,type,code[,verbiage]>` frames |
| `URStreamWaveform` | Waveform type for streaming to UR robot |

### TransactionHandler (upstream — FoundationTransactions)

Lives in `spmFoundationTools/FoundationTransactions`. See `Sources/SwiftRobotics/TransactionHandler/readme.md`.

| Type | Role |
|------|------|
| `TransactionHandler<Command>` | Manages command-ack-response protocol |
| `Transaction` | Per-command state and result publisher |
| `ResourceState` | `.disconnected`, `.idle`, `.busy`, `.error`, `.estop`, `.initializing` |
| `TransactionConcurrency` | `.serial`, `.parallel`, `.exclusive` |
| `TransactionEvent` | Solicited/unsolicited device event |
| `TransactionalCommand` | Protocol commands conform to |

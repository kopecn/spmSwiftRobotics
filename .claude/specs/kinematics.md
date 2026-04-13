# Kinematics

## Denavit-Hartenberg Convention

Standard DH parameters used throughout the library:

| Parameter | Description |
|-----------|-------------|
| `a` | Link length — distance along x-axis |
| `alpha` | Link twist — rotation around x-axis (radians) |
| `d` | Link offset — distance along z-axis |
| `theta` | Joint angle — rotation around z-axis (radians) |

DH transform construction is available via SIMD extensions.

## Forward Kinematics

`ManipulatorProtocol` provides a default `forwardKinematics(posture:) -> PoseRobot` implementation.

Flow:
1. Iterate over the kinematic chain (`links: [KinematicLinkProtocol]`)
2. Call `link.getPose(theta:)` for each link using the joint angle from `posture`
3. Multiply homogeneous transforms (T₀₁ × T₁₂ × … × Tₙ₋₁ₙ)
4. Return resulting `PoseRobot` (end-effector position + orientation)

`ManipulatorSerial` subclasses inherit this; no override needed unless the robot has non-standard kinematics.

## Inverse Kinematics (UR Series)

`URInverseKinematics` provides a closed-form analytical solver for UR robots (8 configurations).

### IKResult

```swift
public enum IKResult {
    case success([PostureSerialRobot])  // one or more valid joint configurations
    case outOfWorkspace                  // target is geometrically unreachable
    case singular                        // robot is at a kinematic singularity
    case noSolution                      // math produced no valid real solution
}
```

### Calling IK

```swift
let result = URInverseKinematics.computeResultFor(
    pose: targetPose,
    whichPose: .rightHandedElbowUp,
    jointWrap: (0, 0, 0, 0, 0, 0, 0, 0)  // default
)
switch result {
case .success(let postures): // use postures[0]
case .outOfWorkspace: // target not reachable
case .singular: // near singularity
case .noSolution: // no real solution found
}
```

### Failure mapping

| Condition | IKResult case |
|-----------|---------------|
| `psi.isNaN \|\| phi.isNaN` | `.outOfWorkspace` |
| `theta5.isNaN` | `.outOfWorkspace` |
| `theta6.isNaN` | `.singular` |
| `theta3.isNaN` | `.outOfWorkspace` |
| All angles finite | `.success([posture])` |

## Trajectory / Streaming

`WaveformStreamer<W: StreamWaveformProtocol>` iterates over a waveform and emits batches.

- `dequeueRadians()` / `dequeueDegrees()` — dequeue next batch of joint positions
- `peekRadians()` — inspect next batch without consuming
- Batch size determined by the UR stream protocol (30 floats = 5 poses per refill)

`URStreamWaveform` is the concrete `StreamWaveformProtocol` for streaming to UR robots.
JSON waveform examples: `Sources/SwiftRoboticAssets/Assets/UR/streamRotateBase.json`.

## Extension Points — Adding a New Manipulator

1. Create `Sources/SwiftRobotics/Manipulator/SpecificManipulators/<Vendor>/<Name>.swift`
2. Subclass `ManipulatorSerial`
3. Define links using `KinematicLinkDH` in the initializer
4. FK is automatic via `ManipulatorProtocol` default implementation
5. For IK: create a `<Name>InverseKinematics.swift` and return `IKResult`; see `URInverseKinematics.swift` as the reference pattern
6. Use the `/add-manipulator` skill for guided step-by-step generation

For URScript development: see `Sources/SwiftRoboticAssets/Assets/UR/readme.md` for the URScript API reference.

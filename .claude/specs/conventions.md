# Conventions

## Naming

| Category | Convention | Examples |
|----------|-----------|---------|
| Types | PascalCase | `KinematicLinkDH`, `ManipulatorSerial`, `IKResult` |
| Properties/Methods | camelCase | `getPose`, `centerOfMass`, `forwardKinematics` |
| Protocols | PascalCase + "Protocol" suffix | `KinematicLinkProtocol`, `ManipulatorProtocol` |
| Enums | PascalCase | `URRobotPostureType`, `ResourceState` |

## File Organization

New files go in the module subfolder that best matches their concern:

- Kinematic math types → `SwiftRobotics/Kinematics/`
- Manipulator models → `SwiftRobotics/Manipulator/SpecificManipulators/<Vendor>/`
- Command definitions → `SwiftRobotics/Commands/`
- Trajectory/waveform → `SwiftRobotics/Trajectory/`
- Socket handlers → `SwiftRoboticsSockets/UniversalRobot/<HandlerName>/`
- Shared socket constants → `SwiftRoboticsSockets/Support/`
- 3D assets → `SwiftRoboticAssets/`

## Denavit-Hartenberg Parameters

| Parameter | Description |
|-----------|-------------|
| `a` | Link length — distance along x-axis |
| `alpha` | Link twist — rotation around x-axis (radians) |
| `d` | Link offset — distance along z-axis |
| `theta` | Joint angle — rotation around z-axis (radians) |

## Transform Representation

- Homogeneous 4×4 transforms via `kvSIMD` types
- DH transform construction via SIMD extensions in `SwiftRobotics/Support/`
- Multiply transforms left-to-right to compose a kinematic chain: T₀ₙ = T₀₁ × T₁₂ × … × Tₙ₋₁ₙ

## Reactive Programming

- Use **OpenCombine** (not Apple Combine) everywhere — required for Linux/Jetson compatibility
- `import OpenCombine` in all files using publishers/subscribers
- Cancellables stored in `Set<AnyCancellable>`

## Access Control

All public API types and their initializers must be declared `public`. This includes:
- Protocol declarations
- `class`/`struct`/`enum` declarations (not just their members)
- `init` methods on public types

Lesson learned: `ManipulatorSerial` and all `ManipulatorUR*` classes were once internal despite having `public init()` — the class declaration itself must be `public`.

## Commit Messages

Use conventional commit prefixes:
- `feat:` — new feature
- `fix:` — bug fix
- `refactor:` — code restructuring without behavior change
- `test:` — adding or updating tests
- `docs:` — documentation only
- `chore:` — build/tooling/config changes

Avoid vague messages like `"neat..."`, `"pushing..."`, `"moving things around"`.

## Cross-Platform Rules

- No iOS/watchOS/tvOS APIs
- No Apple-only Foundation APIs where a cross-platform alternative exists
- Use OpenCombine instead of Combine
- All dependencies must support Linux ARM64 (Jetson)
- SIMD operations must be architecture-agnostic

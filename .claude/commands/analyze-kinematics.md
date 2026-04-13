Analyze the kinematics implementation in SwiftRobotics:

1. List all kinematic link types and their key features
2. Show the relationship between KinematicLinkProtocol implementations
3. Explain the forward kinematics computation flow (default implementation on `ManipulatorProtocol` via DH chain multiplication)
4. Identify which manipulators have inverse kinematics implemented, and show how `IKResult` provides typed failure cases (`.outOfWorkspace`, `.singular`, `.noSolution`)
5. Describe the trajectory/streaming system: `StreamWaveformProtocol`, `WaveformStreamer<W>` batch dequeue, and `URStreamWaveform`

Include relevant file paths and line numbers in your analysis.

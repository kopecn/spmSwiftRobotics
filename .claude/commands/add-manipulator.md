Guide me through adding a new robot manipulator to the SwiftRobotics library:

1. Ask for the robot vendor/model name
2. Ask for the Denavit-Hartenberg parameters (a, alpha, d for each link)
3. Create the appropriate directory structure under `Sources/SwiftRobotics/Manipulator/SpecificManipulators/`
4. Generate the manipulator class conforming to `ManipulatorProtocol`
5. Define kinematic links using `KinematicLinkDH`
6. Optionally set up inverse kinematics stub
7. Add any vendor-specific types or enums needed

Provide code examples following the patterns used in the existing UR manipulator implementation.

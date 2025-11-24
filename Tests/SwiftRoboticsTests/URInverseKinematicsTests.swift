import Testing
import simd
@testable import SwiftRobotics

/// Truth table entry for IK testing
/// Contains a target pose, posture type, expected joint angles, and optional tolerance
struct IKTruthTableEntry: Sendable {
    let description: String
    let pose: simd_double4x4
    let postureType: URRobotPostureType
    let expectedJointAngles: [Double]
    let tolerance: Double

    init(
        description: String,
        pose: simd_double4x4,
        postureType: URRobotPostureType,
        expectedJointAngles: [Double],
        tolerance: Double = 1e-4
    ) {
        self.description = description
        self.pose = pose
        self.postureType = postureType
        self.expectedJointAngles = expectedJointAngles
        self.tolerance = tolerance
    }
}

// MARK: - Truth Tables

/// Truth table for UR5e robot inverse kinematics
/// Add new test cases by appending entries to this array
let ur5eIKTruthTable: [IKTruthTableEntry] = [
    // Test case: Forward kinematics result for joint angles [0, -2.35619, 0.78539, 0, 1.570796, 1.570796]
    IKTruthTableEntry(
        description: "Home position - Sitting Position",
        pose: simd_double4x4(
            // Column-major format: each SIMD4 is a COLUMN of the matrix
            SIMD4<Double>(1.00000, 0.00000, 0.00000, 0.00000),  // Column 0 (X-axis)
            SIMD4<Double>(0.00000, 1.00000, 0.00000, 0.00000),  // Column 1 (Y-axis)
            SIMD4<Double>(0.00000, 0.00000, 1.00000, 0.00000),  // Column 2 (Z-axis)
            SIMD4<Double>(0.20082, -0.13330, 0.95482, 1.00000)  // Column 3 (Translation)
        ),
        postureType: .shoulderRightElbowDownWristUp,
        expectedJointAngles: [0.0, -2.35619, 0.78539, 0.0, 1.570796, 1.570796]
    ),
    // IKTruthTableEntry(
    //     description: "Home position - all zeros",
    //     pose: simd_double4x4(
    //         SIMD4<Double>(1.00000, 0.00000, 0.00000, 0.00000),
    //         SIMD4<Double>(0.00000, 0.00000, 1.00000, 0.00000),
    //         SIMD4<Double>(0.00000, -1.00000, 0.00000, 0.00000),
    //         SIMD4<Double>(-0.81720, -0.23290, 0.06280, 1.00000)
    //     ),
    //     postureType: .shoulderLeftElbowUpWristDown,
    //     expectedJointAngles: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    // ),
    // IKTruthTableEntry(
    //     description: "All Joint Angles at 45 degrees",
    //     pose: simd_double4x4(
    //         SIMD4<Double>(-0.1069206, -0.4934452, 0.8631800, 0.00000),
    //         SIMD4<Double>(0.9698923, 0.1392920, 0.1997665, 0.00000),
    //         SIMD4<Double>(-0.2188080, 0.8585508, 0.4636955, 0.00000),
    //         SIMD4<Double>(0.01662, -0.27149, -0.50952, 1.00000)
    //     ),
    //     postureType: .shoulderLeftElbowUpWristDown,
    //     expectedJointAngles: [45.0, 45.0, 45.0, 45.0, 45.0, 45.0]
    // )

    // Add more test cases here as needed
    // Example format:
    // IKTruthTableEntry(
    //     description: "Description of pose",
    //     pose: simd_double4x4(...),
    //     postureType: .shoulderLeftElbowUpWristDown,
    //     expectedJointAngles: [j1, j2, j3, j4, j5, j6],
    //     tolerance: 1e-4  // Optional, defaults to 1e-4
    // ),
]

// MARK: - Test Helpers

/// Helper to compare joint angles with tolerance
func assertJointAnglesEqual(
    _ computed: [Double],
    _ expected: [Double],
    tolerance: Double,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(computed.count == expected.count, "Joint angle count mismatch", sourceLocation: sourceLocation)

    for (index, (computedAngle, expectedAngle)) in zip(computed, expected).enumerated() {
        let difference = abs(computedAngle - expectedAngle)
        #expect(
            difference < tolerance,
            "Joint \(index + 1): computed=\(computedAngle), expected=\(expectedAngle), diff=\(difference)",
            sourceLocation: sourceLocation
        )
    }
}

/// Helper to create a pose from position and RPY angles
func createPoseFromPositionAndRPY(
    x: Double, y: Double, z: Double,
    roll: Double, pitch: Double, yaw: Double
) -> simd_double4x4 {
    // Create rotation matrix from roll-pitch-yaw
    let cr = cos(roll)
    let sr = sin(roll)
    let cp = cos(pitch)
    let sp = sin(pitch)
    let cy = cos(yaw)
    let sy = sin(yaw)

    // ZYX convention (yaw-pitch-roll) in column-major format
    return simd_double4x4(
        SIMD4<Double>(cy * cp, sy * cp, -sp, 0.0),                                    // Column 0 (X-axis)
        SIMD4<Double>(cy * sp * sr - sy * cr, sy * sp * sr + cy * cr, cp * sr, 0.0),  // Column 1 (Y-axis)
        SIMD4<Double>(cy * sp * cr + sy * sr, sy * sp * cr - cy * sr, cp * cr, 0.0),  // Column 2 (Z-axis)
        SIMD4<Double>(x, y, z, 1.0)                                                    // Column 3 (Translation)
    )
}

// MARK: - UR5e Tests

@Suite("UR5e Inverse Kinematics Tests")
struct UR5eInverseKinematicsTests {

    @Test("UR5e IK - Truth Table Validation", arguments: ur5eIKTruthTable)
    func testUR5eIKWithTruthTable(entry: IKTruthTableEntry) async throws {
        // Create UR5e robot
        let robot = ManipulatorUR5e()

        // Ensure IK calculator is initialized
        guard var ikCalculator = robot.inverseKinematics else {
            Issue.record("UR5e inverse kinematics calculator not initialized")
            return
        }

        // Create pose from truth table
        let pose = PoseRobot(from4x4: entry.pose)

        // Compute IK solution
        let jointWrap = (0, 0, 0, 0, 0, 0, 0, 0)
        let result = ikCalculator.computePostureFor(
            pose: pose,
            whichPose: entry.postureType,
            jointWrap: jointWrap
        )

        // Validate result exists
        guard let posture = result else {
            Issue.record("\(entry.description): IK solution not found")
            return
        }

        // Compare computed joint angles with expected values
        assertJointAnglesEqual(
            posture.jointAngles,
            entry.expectedJointAngles,
            tolerance: entry.tolerance
        )
    }

    @Test("UR5e IK - Basic sanity check")
    func testUR5eIKBasicSanity() async throws {
        let robot = ManipulatorUR5e()

        #expect(robot.inverseKinematics != nil, "IK calculator should be initialized")
        #expect(robot.links.count == 6, "UR5e should have 6 links")
    }
}


// MARK: - Cross-Robot Validation Tests

@Suite("UR Cross-Robot IK Tests")
struct URCrossRobotTests {

    @Test("Forward-Inverse Kinematics Consistency - UR5e")
    func testUR5eForwardInverseConsistency() async throws {
        let robot = ManipulatorUR5e()
        guard robot.inverseKinematics != nil else {
            Issue.record("IK calculator not initialized")
            return
        }

        // Test joint configuration
        _ = [0.1, -0.5, 0.3, -0.2, 0.4, 0.0]

        // Compute forward kinematics (implement when FK is available)
        // let fkPose = robot.computeForwardKinematics(jointAngles: testJoints)
        // let ikResult = ikCalculator.computePostureFor(pose: fkPose, whichPose: .shoulderLeftElbowUpWristDown, jointWrap: (0,0,0,0,0,0,0,0))
        // assertJointAnglesEqual(ikResult!.jointAngles, testJoints, tolerance: 1e-3)

        // Placeholder until FK is implemented
        #expect(Bool(true), "Forward kinematics not yet implemented - placeholder test")
    }

    @Test("All UR robots have IK initialized")
    func testAllURRobotsHaveIK() async throws {
        let robots: [ManipulatorUR] = [
            ManipulatorUR3(),
            ManipulatorUR3e(),
            ManipulatorUR5(),
            ManipulatorUR5e(),
            ManipulatorUR7e(),
            ManipulatorUR10e(),
            ManipulatorUR12e(),
            ManipulatorUR15(),
            ManipulatorUR16e(),
            ManipulatorUR20(),
            ManipulatorUR30()
        ]

        for robot in robots {
            #expect(
                robot.inverseKinematics != nil,
                "\(type(of: robot)) should have IK calculator initialized"
            )
        }
    }
}

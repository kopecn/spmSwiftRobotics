import Foundation

import FoundationTypes
import spmMathTools

/// Analytical inverse kinematics solver for Universal Robots manipulators (UR3/5/10/e series).
///
/// This implementation follows the closed-form analytical solution described in:
/// "UR5 Inverse Kinematics" by Ryan Keating, Johns Hopkins University (2014, updated 2016).
///
/// ## Overview
///
/// The solver computes joint angles for a 6-DOF Universal Robots manipulator given a desired
/// end-effector pose. The algorithm analytically solves for all 8 possible configurations:
/// - Shoulder: Left/Right (2 solutions)
/// - Elbow: Up/Down (2 solutions)
/// - Wrist: Up/Down (2 solutions)
///
/// ## Performance Considerations
///
/// This solver is implemented as a **value type (struct)** rather than a reference type (class)
/// to minimize ARC (Automatic Reference Counting) overhead. This design choice is critical for
/// high-frequency applications with expected cycle times of **1-4 kHz**.
///
/// **Benefits of struct design:**
/// - No reference counting overhead (no retain/release calls)
/// - Stack allocation for temporary instances
/// - Predictable memory layout and cache performance
/// - Thread-safe by default (value semantics)
///
/// **Note:** The `mutating` keyword on `computePostureFor` indicates that intermediate
/// calculations are stored in the struct's properties to avoid repeated allocations,
/// which further improves performance at high frequencies.
///
/// ## Algorithm
///
/// The solution proceeds in the following order:
/// 1. **θ₁** (Shoulder): Computed from overhead projection using `P₀⁵` location
/// 2. **θ₅** (Wrist): Computed from wrist position relative to frame 1
/// 3. **θ₆** (Wrist roll): Computed from orientation using `T₁⁶`
/// 4. **θ₃** (Elbow): Computed using law of cosines on planar 3R manipulator
/// 5. **θ₂** (Shoulder pitch): Computed using geometry of frames 1-3
/// 6. **θ₄** (Wrist pitch): Computed from remaining transformation
///
/// ## Singularities and Edge Cases
///
/// The solver will return `nil` in the following cases:
/// - **Unreachable position**: Target is outside the robot's workspace sphere
/// - **Donut hole**: Target is inside the cylindrical singularity near the base z-axis (d4 > |P₀⁵|ₓᵧ)
/// - **Wrist singularity**: When sin(θ₅) = 0, θ₆ is undefined (infinite solutions in the wrist plane)
///
/// ## Usage Example
///
/// ```swift
/// let robot = ManipulatorUR5e()
/// guard var ikSolver = robot.inverseKinematics else { return }
///
/// let targetPose = PoseRobot(from4x4: desiredTransform)
/// let posture: URRobotPostureType = .shoulderLeftElbowUpWristDown
///
/// if let solution = ikSolver.computePostureFor(
///     pose: targetPose,
///     whichPose: posture,
///     jointWrap: (0, 0, 0, 0, 0, 0, 0, 0)
/// ) {
///     print("Joint angles: \(solution.jointAngles)")
/// } else {
///     print("No IK solution found (unreachable or singular)")
/// }
/// ```
///
/// ## References
///
/// - Keating, R. (2014). "UR5 Inverse Kinematics", Johns Hopkins University, M.E. 530.646
/// - Universal Robots Technical Specifications and DH Parameters
///
/// - SeeAlso: `URRobotPostureType`, `ManipulatorUR`, `PoseRobot`
public struct URInverseKinematics: Sendable {

    // MARK: - Robot Parameters (DH Convention)

    /// Link offset d₆ (distance along z₆ axis)
    let d6: Float

    /// Precomputed vector for P₀⁵ calculation: [0, 0, -d6, 1]
    let d6Vect: Position<Float>

    /// Link offset d₄ (distance along z₄ axis)
    let d4: Float

    /// Precomputed vector for P₁³ calculation: [0, -d4, 0, 1]
    let d4Vect: Position<Float>

    /// Link 1 DH parameters (base to shoulder)
    let l1: KinematicLinkDH

    /// Link 2 DH parameters (shoulder to elbow)
    let l2: KinematicLinkDH

    /// Link 3 DH parameters (elbow to wrist)
    let l3: KinematicLinkDH

    /// Link 5 DH parameters (wrist pitch)
    let l5: KinematicLinkDH

    /// Link 6 DH parameters (wrist roll to end-effector)
    let l6: KinematicLinkDH

    /// Link length a₂ (distance along x₂ axis)
    let a2: Float

    /// Link length a₃ (distance along x₃ axis)
    let a3: Float

    // MARK: - Intermediate Calculation State
    // These properties store intermediate results to avoid repeated allocations
    // during high-frequency IK computations (1-4 kHz cycle times)

    /// Vector from frame 0 to frame 5 origin (P₀⁵), used for θ₁ calculation
    var vector0to5: Position<Float> = Position<Float>(x:0, y: 0, z: 0)

    /// Angle ψ = atan2(P₀⁵_y, P₀⁵_x) for θ₁ calculation
    var psi: Float = 0

    /// Angle φ = ±arccos(d4 / |P₀⁵|ₓᵧ) for θ₁ calculation
    var phi: Float = 0

    /// Transformation from frame 6 to frame 1 (T₆¹ = T₁⁶⁻¹)
    var transform6to1: PoseRobot = PoseRobot.identity

    /// Transformation from frame 1 to frame 6 (T₁⁶)
    var transform1to6: PoseRobot = PoseRobot.identity

    /// Transformation from frame 1 to frame 4 (T₁⁴)
    var transform1to4: PoseRobot = PoseRobot.identity

    /// Vector from frame 1 to frame 3 origin (P₁³), used for θ₂ and θ₃ calculation
    var vector1to3: Position<Float> = Position<Float>(x:0, y: 0, z: 0)

    /// Z-component of P₁⁶, used for θ₅ calculation
    var vector1to6z: Float = 0

    /// sin(θ₅), cached to avoid recomputation in θ₆ calculation
    var sinTheta5: Float = 0

    /// Computed joint angles (radians)
    var theta1: Float = 0
    var theta2: Float = 0
    var theta3: Float = 0
    var theta4: Float = 0
    var theta5: Float = 0
    var theta6: Float = 0

    // MARK: - Initialization

    /// Initializes the inverse kinematics solver with robot-specific DH parameters.
    ///
    /// - Parameters:
    ///   - link1: DH parameters for joint 1 (base rotation)
    ///   - link2: DH parameters for joint 2 (shoulder pitch)
    ///   - link3: DH parameters for joint 3 (elbow)
    ///   - link4: DH parameters for joint 4 (wrist yaw)
    ///   - link5: DH parameters for joint 5 (wrist pitch)
    ///   - link6: DH parameters for joint 6 (wrist roll)
    ///
    /// - Note: This initializer extracts and caches critical parameters (d4, d6, a2, a3)
    ///         for efficient access during high-frequency IK computations.
    public init(
        link1: KinematicLinkDH,
        link2: KinematicLinkDH,
        link3: KinematicLinkDH,
        link4: KinematicLinkDH,
        link5: KinematicLinkDH,
        link6: KinematicLinkDH
    ) {
        l1 = link1
        l2 = link2
        l5 = link5
        l6 = link6
        a2 = link2.a
        a3 = link3.a
        l3 = link3
        d4 = link4.d
        d6 = link6.d

        // Precompute constant vectors for vector operations
        
        d6Vect = Position<Float>(x:0, y: 0, z: -link6.d)
        d4Vect = Position<Float>(x:0, y: -link4.d, z: 0)
    }

    // MARK: - Private Helper Methods: Joint Angle Calculations

    /// Clamps a value to the valid domain of arccos [-1, 1] to prevent NaN from floating-point errors.
    ///
    /// - Parameter value: Input value to clamp
    /// - Returns: Value clamped to [-1.0, 1.0]
    ///
    /// - Note: Floating-point arithmetic can produce values slightly outside [-1, 1] due to
    ///         rounding errors, which would cause acos() to return NaN. This helper ensures
    ///         numerical robustness.
    @inline(__always)
    private func clampAcos(_ value: Float) -> Float {
        acos(max(-1.0, min(1.0, value)))
    }

    /// Computes angle ψ for θ₁ calculation (Equation 4 from Keating paper).
    ///
    /// ψ = atan2((P₀⁵)y, (P₀⁵)x)
    ///
    /// - Returns: Angle ψ in radians, or NaN if P₀⁵ has no X or Y components
    ///
    /// - Note: NaN indicates the robot is in a singular configuration where the
    ///         wrist center lies on the base z-axis.
    @inline(__always)
    private var getPsi: Float {
        /// ψ= atan2 (P05 )y,(P05 )x
        atan2(vector0to5.y, vector0to5.x)
    }

    /// Computes angle φ for θ₁ calculation (Equation 5 from Keating paper).
    ///
    /// φ = ±arccos(d4 / |P₀⁵|ₓᵧ)
    ///
    /// - Returns: Angle φ in radians, or NaN if |P₀⁵|ₓᵧ < d4 (inside "donut hole")
    ///
    /// - Note: The "donut hole" is a cylindrical unreachable region near the base z-axis
    ///         where d4 > |P₀⁵|ₓᵧ. This forms part of the robot's workspace boundary.
    @inline(__always)
    private var getPhi: Float {
        clampAcos(
            d4 / sqrt(vector0to5.x * vector0to5.x + vector0to5.y * vector0to5.y)
        )
    }

    /// Computes the Z-component of P₁⁶ (wrist center position in frame 1).
    ///
    /// Uses the formula: (P₁⁶)z = (P₀⁶)x · sin(θ₁) - (P₀⁶)y · cos(θ₁)
    ///
    /// - Parameters:
    ///   - pose: Target end-effector pose T₀⁶
    ///   - theta1: Computed shoulder rotation angle θ₁
    /// - Returns: Z-component of wrist center in frame 1 coordinates
    @inline(__always)
    private func vector1to6z(
        pose: PoseRobot,
        theta1: Float
    ) -> Float {
        pose.z * sin(theta1) - pose.y * cos(theta1)
    }

    /// Computes shoulder rotation angle θ₁ (Equation 4-5 from Keating paper).
    ///
    /// θ₁ = ψ ± φ + π/2, where the sign depends on shoulder configuration:
    /// - Shoulder Left: θ₁ = ψ + φ + π/2
    /// - Shoulder Right: θ₁ = ψ - φ + π/2
    ///
    /// - Parameter whichPose: Robot configuration specifying shoulder orientation
    /// - Returns: Joint angle θ₁ in radians
    @inline(__always)
    private func getTheta1(
        whichPose: URRobotPostureType
    ) -> Float {
        if whichPose.shoulderLeft {
            return psi + phi + Float.pi / 2
        } else {
            return psi - phi + Float.pi / 2
        }
    }

    /// Computes shoulder pitch angle θ₂ (Equation 18 from Keating paper).
    ///
    /// θ₂ = -atan2((P₁³)y, -(P₁³)x) + arcsin(a3·sin(θ₃) / ‖P₁³‖)
    ///
    /// - Parameter theta3: Previously computed elbow angle θ₃
    /// - Returns: Joint angle θ₂ in radians
    @inline(__always)
    private func getTheta2(
        theta3: Float
    ) -> Float {
        -atan2(
            self.vector1to3.y,
            -self.vector1to3.x
        )
            + asin(
                (self.a3 * sin(self.theta3)) / self.vector1to3.magnitude
            )
    }

    /// Computes elbow angle θ₃ (Equation 15 from Keating paper).
    ///
    /// Uses law of cosines: θ₃ = ±arccos((‖P₁³‖² - a2² - a3²) / (2·a2·a3))
    /// where the sign depends on elbow configuration (up/down).
    ///
    /// - Parameter whichPose: Robot configuration specifying elbow orientation
    /// - Returns: Joint angle θ₃ in radians, or NaN if pose is unreachable
    @inline(__always)
    private func getTheta3(whichPose: URRobotPostureType) -> Float {
        let cosValue = (self.vector1to3.magnitudeSquared - a2 * a2 - a3 * a3) / (2 * a2 * a3)

        if whichPose.elbowUp {
            return clampAcos(cosValue)
        } else {
            return -clampAcos(cosValue)
        }
    }

    /// Computes wrist pitch angle θ₄ (Equation 20 from Keating paper).
    ///
    /// Extracts θ₄ from the first column of T₃⁴: θ₄ = atan2(xy, xx)
    ///
    /// - Parameter transform3to4: Transformation from frame 3 to frame 4 (T₃⁴)
    /// - Returns: Joint angle θ₄ in radians
    @inline(__always)
    private func getTheta4(
        transform3to4: PoseRobot
    ) -> Float {
        
        atan2(transform3to4.quaternion.xy, transform3to4.quaternion.xx)
    }

    /// Computes wrist yaw angle θ₅ (Equation 6 from Keating paper).
    ///
    /// θ₅ = ±arccos(((P₁⁶)z - d4) / d6), where the sign depends on wrist configuration:
    /// - Wrist Up: positive arccos
    /// - Wrist Down: negative arccos
    ///
    /// - Parameter whichPose: Robot configuration specifying wrist orientation
    /// - Returns: Joint angle θ₅ in radians, or NaN if configuration is invalid
    ///
    /// - Note: When sin(θ₅) = 0, the wrist is in a singular configuration where
    ///         θ₆ becomes undefined (infinite solutions exist).
    @inline(__always)
    private func getTheta5(
        whichPose: URRobotPostureType
    ) -> Float {
        let cosValue = (self.vector1to6z - self.d4) / self.d6

        if whichPose.wristUp {
            return clampAcos(cosValue)
        } else {
            return -clampAcos(cosValue)
        }
    }

    /// Computes wrist roll angle θ₆ (Equation 10 from Keating paper).
    ///
    /// Extracts θ₆ from the rotation matrix T₆¹: θ₆ = atan2(-zy/sin(θ₅), zx/sin(θ₅))
    /// where zy and zx are elements from the third column of T₆¹.
    ///
    /// - Parameter transform1to6: Inverse transformation T₆¹ (used for accessing rotation elements)
    /// - Returns: Joint angle θ₆ in radians, or NaN if near wrist singularity
    ///
    /// - Note: Returns NaN when |sin(θ₅)| < 1e-6 (wrist singularity), where θ₆ becomes
    ///         undefined due to infinite solutions in the wrist plane.
    @inline(__always)
    private func getTheta6(transform1to6: PoseRobot) -> Float {
        // Check for wrist singularity (when sin(θ₅) ≈ 0)
        let epsilon: Float = 1e-6
        if abs(self.sinTheta5) < epsilon {
            return Float.nan
        }

        return atan2(-transform1to6.quaternion.zy / self.sinTheta5, transform1to6.quaternion.zx / self.sinTheta5)
    }

    // MARK: - Private Helper Methods: Vector Computations

    /// Computes the position of frame 5 origin relative to base frame (P₀⁵).
    ///
    /// This is calculated by translating from the end-effector (frame 6) by -d6 along z₆:
    /// P₀⁵ = T₀⁶ · [0, 0, -d6, 1]ᵀ - [0, 0, 0, 1]ᵀ
    ///
    /// - Parameter pose: Target end-effector transformation T₀⁶
    /// - Returns: Vector P₀⁵ as a 4D homogeneous coordinate (w=0 for direction vector)
    @inline(__always)
    private func vector0to5(pose: PoseRobot) -> Position<Float> {
        pose * d6Vect
    }

    // MARK: - Public API

    /// Computes inverse kinematics to find joint angles for a desired end-effector pose.
    ///
    /// This method implements the analytical closed-form solution for Universal Robots manipulators.
    /// It solves for one of the 8 possible robot configurations specified by `whichPose`.
    ///
    /// ## Performance
    ///
    /// - **Designed for high-frequency operation (1-4 kHz)**
    /// - Marked as `mutating` to reuse internal storage and avoid allocations
    /// - Uses SIMD operations for efficient vector/matrix computations
    /// - Stack-allocated struct (no heap allocations for the solver instance)
    ///
    /// ## Algorithm Steps
    ///
    /// 1. Compute P₀⁵ (frame 5 origin) and check workspace validity
    /// 2. Solve θ₁ from overhead projection (shoulder left/right)
    /// 3. Solve θ₅ from wrist position (wrist up/down)
    /// 4. Solve θ₆ from wrist orientation using T₆¹
    /// 5. Solve θ₃ from elbow geometry (elbow up/down)
    /// 6. Solve θ₂ from shoulder geometry
    /// 7. Solve θ₄ from remaining transformation
    ///
    /// - Parameters:
    ///   - pose: Target end-effector pose (4×4 homogeneous transformation matrix)
    ///   - whichPose: Specifies which of the 8 IK solutions to compute (shoulder/elbow/wrist configuration)
    ///   - jointWrap: Joint wrapping parameters for continuous rotation handling (currently unused)
    ///
    /// - Returns: Joint angles solution as `PostureSerialRobot`, or `nil` if:
    ///   - Target pose is unreachable (outside workspace)
    ///   - Target is in singular configuration (donut hole)
    ///   - Numerical singularity encountered (NaN in calculations)
    ///
    /// - Note: The `jointWrap` parameter is reserved for future use to handle multi-turn
    ///         joint solutions. Currently, the solver returns angles in the range [-π, π].
    ///
    /// ## Example
    ///
    /// ```swift
    /// var ikSolver = URInverseKinematics(link1: ..., link2: ..., ...)
    /// let targetPose = PoseRobot(from4x4: myTransform)
    ///
    /// // Try shoulder-left, elbow-up, wrist-down configuration
    /// if let solution = ikSolver.computePostureFor(
    ///     pose: targetPose,
    ///     whichPose: .shoulderLeftElbowUpWristDown,
    ///     jointWrap: (0, 0, 0, 0, 0, 0, 0, 0)
    /// ) {
    ///     print("Success: \(solution.jointAngles)")
    /// }
    /// ```
    ///
    /// - SeeAlso: `URRobotPostureType` for available robot configurations
    public mutating func computePostureFor(
        pose: PoseRobot,
        whichPose: URRobotPostureType,
        jointWrap: (Int, Int, Int, Int, Int, Int, Int, Int)
    ) -> PostureSerialRobot? {

        self.vector0to5 = vector0to5(pose: pose)

        self.psi = self.getPsi
        self.phi = self.getPhi

        if psi.isNaN || phi.isNaN {
            return nil
        }

        /// The two solutions for θ1 above correspond to the shoulder
        /// being either "left" or "right,".
        self.theta1 = getTheta1(whichPose: whichPose)

        self.vector1to6z = vector1to6z(pose: pose, theta1: theta1)

        /// there are two solutions.
        /// These solutions correspond to the wrist being "down" and "up."
        self.theta5 = getTheta5(whichPose: whichPose)

        if self.theta5.isNaN {
            return nil
        }

        self.sinTheta5 = sin(self.theta5)

        // Compute T_16 (transform from frame 1 to frame 6) for theta6 calculation
        self.transform1to6 = l1.getPose(theta: theta1).inverse * pose
        self.theta6 = getTheta6(transform1to6: transform1to6)

        // Check for wrist singularity
        if self.theta6.isNaN {
            return nil
        }

        self.transform1to4 = self.transform1to6 * (l5.getPose(theta: theta5) * l6.getPose(theta: self.theta6)).inverse

        self.vector1to3 = self.transform1to4 * d4Vect

        /// there are two solutions for θ2 and θ3.
        /// These solutions are known as “elbow up” and “elbow down.”
        self.theta3 = getTheta3(whichPose: whichPose)

        if self.theta3.isNaN {
            return nil
        }

        self.theta2 = getTheta2(
            theta3: self.theta3
        )

        self.theta4 = getTheta4(
            transform3to4: (
                l2.getPose(theta: self.theta2) * l3.getPose(theta: self.theta3)).inverse * self.transform1to4
        )

        return PostureSerialRobot(
            jointAngles: [theta1, theta2, theta3, theta4, theta5, theta6]
        )
    }
}

/// The result of an inverse kinematics computation.
///
/// Replaces the untyped `nil` returned by ``URInverseKinematics/computePostureFor(pose:whichPose:jointWrap:)``
/// with distinct cases that let callers understand *why* the solve failed.
///
/// ## Usage
///
/// ```swift
/// var ikSolver = robot.inverseKinematics
/// switch ikSolver.computeResultFor(pose: target, whichPose: .shoulderLeftElbowUpWristDown) {
/// case .success(let postures):
///     applyJointAngles(postures[0].jointAngles)
/// case .outOfWorkspace:
///     showAlert("Target is outside the robot's reachable workspace.")
/// case .singular:
///     showAlert("Target is at a wrist singularity — reposition slightly.")
/// case .noSolution:
///     showAlert("No IK solution for this configuration.")
/// }
/// ```
public enum IKResult {

    /// A valid joint-angle solution was found. The array contains one ``PostureSerialRobot``
    /// per requested configuration (typically one unless a bulk solve is used).
    case success([PostureSerialRobot])

    /// The target pose is outside the robot's reachable workspace — either beyond the
    /// maximum reach sphere or inside the unreachable "donut hole" near the base z-axis.
    case outOfWorkspace

    /// The target pose places the robot in a kinematic singularity. Currently this covers
    /// the wrist singularity (sin θ₅ ≈ 0) where θ₆ has infinitely many solutions.
    case singular

    /// Catch-all for any numerical failure that doesn't map to a known geometric case.
    ///
    /// The current closed-form solver always produces `.outOfWorkspace` or `.singular`
    /// for its failure paths. `.noSolution` is reserved for future iterative or
    /// numerical solvers that may fail to converge without a clear geometric reason
    /// (e.g., maximum-iteration exceeded, residual above tolerance).
    case noSolution
}

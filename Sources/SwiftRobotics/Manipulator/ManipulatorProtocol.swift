import Foundation
import simd

public protocol ManipulatorProtocol {
    var links: [any KinematicLinkProtocol] { get }
}

extension ManipulatorProtocol {
    /// Computes the forward kinematics end-effector pose for the given posture.
    ///
    /// Chains DH link transforms using matrix multiplication:
    /// `T_0_n = T_0_1 * T_1_2 * ... * T_(n-1)_n`
    ///
    /// - Parameter posture: The robot posture containing joint angles (one per link, in radians).
    /// - Returns: The end-effector pose in world space, or `nil` if the posture joint count
    ///   doesn't match the number of links.
    public func forwardKinematics(posture: PostureSerialRobot) -> PoseRobot? {
        let angles = posture.jointAngles
        guard angles.count == links.count else { return nil }

        var transform = matrix_identity_float4x4
        for (link, theta) in zip(links, angles) {
            transform = transform * link.getPose(theta: theta).homogeneousTransform
        }
        return PoseRobot(from4x4: transform)
    }
}

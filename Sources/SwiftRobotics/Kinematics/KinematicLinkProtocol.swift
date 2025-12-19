import Foundation
import FoundationTypes

/// Foundational kinematic link protocol
public protocol KinematicLinkProtocol: Identifiable, Sendable {
    var id: UUID { get }
    var type: KinematicLinkType { get }
    var renderingAsset: RobotRenderingAssetType? { get }
    func getPose(theta: Float) -> SpatialPose<Float>
}

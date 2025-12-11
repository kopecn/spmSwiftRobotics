import Foundation
import simd

/// Foundational kinematic link protocol
public protocol KinematicLinkProtocol: Identifiable {
    var id: UUID { get }
    var type: KinematicLinkType { get }
    var renderingAsset: RobotRenderingAssetType? { get }
    func getPose(theta: Float) -> simd_float4x4
}

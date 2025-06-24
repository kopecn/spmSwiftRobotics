import Foundation
import simd

/// Foundational kinematic link protocol
public protocol KinematicLinkProtocol: Identifiable {
    var id: UUID { get }

    var pose: simd_double4x4 { get set }
    var type: KinematicLinkType { get }
}
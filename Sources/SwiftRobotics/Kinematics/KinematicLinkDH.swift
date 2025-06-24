import Foundation
import simd

/// A kinematic link using Denavit-Hartenberg parameters
public class KinematicLinkDH: KinematicLinkProtocol {
    public var id: UUID
    public var pose: simd_double4x4
    public var type: KinematicLinkType = .devHart

    public init(
        id: UUID = UUID(),
        pose: simd_double4x4, 
        type: KinematicLinkType
    ) {
        self.pose = pose
        self.type = type
        self.id = id
    }
}
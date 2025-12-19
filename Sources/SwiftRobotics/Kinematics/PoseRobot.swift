import FoundationTypes
import simd

/// Typealias for a robot pose using Float precision.
public typealias PoseRobot = SpatialPose<Float>

extension PoseRobot {
    /// Convenience initializer from a 4x4 homogeneous transform matrix.
    /// - Parameter pose: The 4x4 transformation matrix.
    public init(from4x4 pose: simd_float4x4) {
        self.init(homogeneousTransform: pose)
    }
}

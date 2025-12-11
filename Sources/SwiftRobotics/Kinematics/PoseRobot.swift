import simd

public class PoseRobot {
    public var pose: simd_float4x4

    public init(from4x4 pose: simd_float4x4) {
        self.pose = pose
    }
}

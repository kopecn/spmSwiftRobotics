import simd


public class PoseRobot {
    public var pose: simd_double4x4

    public init(from4x4 pose: simd_double4x4) {
        self.pose = pose
    }
}
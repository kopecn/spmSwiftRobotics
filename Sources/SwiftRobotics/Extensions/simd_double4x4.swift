import simd

extension simd_double4x4 {
    public init(fromDH a: Double, d: Double, alpha: Double) {
        self = matrix_identity_double4x4
    }
}
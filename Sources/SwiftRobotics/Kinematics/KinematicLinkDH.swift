import Foundation
import simd

/// A kinematic link using Denavit-Hartenberg parameters
public class KinematicLinkDH: KinematicLinkProtocol {
    // MARK: - Protocol Properties

    public var id: UUID
    public var type: KinematicLinkType = .devHart
    public var renderingAsset: RobotRenderingAssetType?

    // MARK: - Properties

    /// Link length (distance along x axis)
    public let a: Double
    /// Link twist (angle in radians around x axis)
    public let alpha: Double
    /// sine of the link twist (angle in radians around x axis)
    public let sa: Double
    /// cosine of the link twist (angle in radians around x axis)
    public let ca: Double
    /// Link offset (distance along z axis)
    public let d: Double
    /// Mass
    public var mass: Double?
    /// Center of mass
    public var centerOfMass: [Double]?
    /// Inertia matrix
    public var inertiaMatrix: [Double]?

    public init(
        id: UUID = UUID(),
        a: Double,
        alpha: Double,
        d: Double,
        mass: Double? = nil,
        centerOfMass: [Double]? = nil,
        inertiaMatrix: [Double]? = nil,
        renderingAsset: RobotRenderingAssetType? = nil
    ) {
        self.id = id
        self.a = a
        self.alpha = alpha
        sa = sin(alpha)
        ca = cos(alpha)
        self.d = d
        self.mass = mass
        self.centerOfMass = centerOfMass
        self.inertiaMatrix = inertiaMatrix
        self.renderingAsset = renderingAsset
    }

    public func getPose(theta: Double) -> simd_double4x4 {
        simd_double4x4(denavitHartenberg: a, ca: ca, sa: sa, d: d, theta: theta)
    }
}

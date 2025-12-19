import Foundation
import FoundationTypes
import simd
import spmMathTools

/// A kinematic link using Denavit-Hartenberg parameters
public struct KinematicLinkDH: KinematicLinkProtocol {
    // MARK: - Protocol Properties

    public let id: UUID
    public let type: KinematicLinkType
    public let renderingAsset: RobotRenderingAssetType?

    // MARK: - Properties

    /// Link length (distance along x axis)
    public let a: Float
    /// Link twist (angle in radians around x axis)
    public let alpha: Float
    /// sine of the link twist (angle in radians around x axis)
    public let sa: Float
    /// cosine of the link twist (angle in radians around x axis)
    public let ca: Float
    /// Link offset (distance along z axis)
    public let d: Float
    /// Mass
    public let mass: Float?
    /// Center of mass
    public let centerOfMass: [Float]?
    /// Inertia matrix
    public let inertiaMatrix: [Float]?

    public init(
        id: UUID = UUID(),
        a: Float,
        alpha: Float,
        d: Float,
        mass: Float? = nil,
        centerOfMass: [Float]? = nil,
        inertiaMatrix: [Float]? = nil,
        renderingAsset: RobotRenderingAssetType? = nil
    ) {
        self.id = id
        self.type = .devHart
        self.a = a
        self.alpha = alpha
        self.sa = sin(alpha)
        self.ca = cos(alpha)
        self.d = d
        self.mass = mass
        self.centerOfMass = centerOfMass
        self.inertiaMatrix = inertiaMatrix
        self.renderingAsset = renderingAsset
    }

    public func getPose(theta: Float) -> SpatialPose<Float> {
        SpatialPose<Float>(denavitHartenberg: a, ca: ca, sa: sa, d: d, theta: theta)
    }
}

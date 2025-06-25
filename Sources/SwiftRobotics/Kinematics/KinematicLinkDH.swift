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
    /// sine of the link twist (angle in radians around x axis)
    public let sa: Double
    /// cosine of the link twist (angle in radians around x axis)
    public let ca: Double
    ///Link offset (distance along z axis)
    public let d: Double


    public init(
        id: UUID = UUID(),
        a: Double,
        d: Double
    ) {
        self.id = id
        self.a = a
        self.sa = sin(a)
        self.ca = cos(a)
        self.d = d
    }

    public func getPose(theta: Double) -> simd_double4x4 {
        return simd_double4x4(denavitHartenberg: a, ca: ca, sa: sa, d: d, theta: theta)
    }
}
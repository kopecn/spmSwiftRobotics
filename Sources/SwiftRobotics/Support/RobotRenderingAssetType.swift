import Foundation

public enum RobotRenderingAssetType: Sendable {
    case uriAsset(assetlocation: URL)
    case daeAsset
    case usdzAsset

    /// Planned Future Assets
    // case arrow
    // case camera
    // case capsule
    // case circle
    // case cone
    // case cube
    // case cylinder
    // case gui
    // case image
    // case line
    // case particle
    // case plane
    // case point
    // case polygon
    // case quad
    // case rectangle
    // case skybox
    // case sphere
    // case spline
    // case sprite
    // case terrain
    // case text
    // case torus
    // case triangle
    // case tube
}

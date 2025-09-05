import Foundation

public protocol ManipulatorProtocol {
    var links: [any KinematicLinkProtocol] { get }
}

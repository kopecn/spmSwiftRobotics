public class ManipulatorSerial: ManipulatorProtocol {
    public var links: [any KinematicLinkProtocol]

    /// Initializes a new `ManipulatorSerial` with an empty array of links.
    public init?() {
        links = []
    }

    public init?(links: [any KinematicLinkProtocol]) {
        self.links = links
    }
}

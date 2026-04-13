public class ManipulatorSerial: ManipulatorProtocol {
    public var links: [any KinematicLinkProtocol]

    /// Initializes a new `ManipulatorSerial` with an empty array of links.
    ///
    /// - Note: Declared failable (`init?`) so that subclasses — such as `ManipulatorUR` —
    ///   can override it with their own failable init (Swift requires the override to match
    ///   failability or be more failable). This init itself never returns `nil`.
    public init?() {
        links = []
    }

    /// Initializes a new `ManipulatorSerial` with the given links.
    ///
    /// - Note: Declared failable for the same subclass-override reason as `init?()`.
    ///   This init never returns `nil`.
    public init?(links: [any KinematicLinkProtocol]) {
        self.links = links
    }
}

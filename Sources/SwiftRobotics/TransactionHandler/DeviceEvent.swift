import Foundation

/// An event emitted by a device during operation.
///
/// Events can be either **solicited** (associated with a specific transaction)
/// or **unsolicited** (general device notifications not tied to any command).
///
/// ## Solicited Events
/// These events are emitted during the execution of a transaction and are
/// routed to that transaction's `eventPublisher`. Examples include:
/// - Progress updates during motion
/// - Waypoint/node passage notifications
/// - Streaming data from the device
///
/// ## Unsolicited Events
/// These events occur independently of any transaction and are emitted
/// on the handler's `unsolicitedEventPublisher`. Examples include:
/// - Collision detection
/// - Safety system triggers
/// - Device state changes
/// - Hardware warnings or errors
///
/// ## Event Codes
/// The `code` property allows end users to define their own filtering
/// and assignment schemes. Common patterns include:
/// - Numeric ranges for categories (1000-1999 for motion, 2000-2999 for safety)
/// - Bitmask flags for multiple attributes
/// - Direct enumeration mapping
public struct DeviceEvent: Sendable, Codable {
    /// User-assignable event code for filtering and categorization.
    ///
    /// The interpretation of this code is application-specific.
    /// Use it to implement your own event filtering or routing logic.
    public let code: Int

    /// Timestamp when the event was received/created.
    public let timestamp: Date

    /// Optional payload data associated with the event.
    ///
    /// The format and content is event-specific. May contain:
    /// - JSON data
    /// - Position coordinates
    /// - Error messages
    /// - Sensor readings
    public let payload: String?

    /// Transaction ID if this is a solicited event, nil for unsolicited.
    ///
    /// When set, the event will be routed to the specific transaction's
    /// `eventPublisher`. When nil, the event is routed to the handler's
    /// `unsolicitedEventPublisher`.
    public let transactionID: Int?

    /// Resource identifier for the device that emitted this event.
    public let resourceID: String?

    /// Creates a new device event.
    ///
    /// - Parameters:
    ///   - code: User-assignable event code for filtering.
    ///   - payload: Optional payload data.
    ///   - transactionID: Transaction ID for solicited events, nil for unsolicited.
    ///   - resourceID: Optional resource identifier.
    ///   - timestamp: Event timestamp. Defaults to current time.
    public init(
        code: Int,
        payload: String? = nil,
        transactionID: Int? = nil,
        resourceID: String? = nil,
        timestamp: Date = Date()
    ) {
        self.code = code
        self.payload = payload
        self.transactionID = transactionID
        self.resourceID = resourceID
        self.timestamp = timestamp
    }

    /// Whether this is a solicited event (associated with a transaction).
    public var isSolicited: Bool {
        transactionID != nil
    }

    /// Whether this is an unsolicited event (not associated with any transaction).
    public var isUnsolicited: Bool {
        transactionID == nil
    }
}

// MARK: - Common Event Code Ranges (Suggestions)

extension DeviceEvent {
    /// Suggested event code ranges for common categories.
    ///
    /// These are suggestions only; applications can define their own schemes.
    public enum SuggestedCodeRange {
        /// Motion-related events (progress, waypoints, etc.)
        public static let motion = 1000..<2000

        /// Safety-related events (collisions, estop, limits)
        public static let safety = 2000..<3000

        /// Status/diagnostic events
        public static let status = 3000..<4000

        /// User-defined application events
        public static let application = 4000..<5000

        /// Streaming data events
        public static let streaming = 5000..<6000
    }
}

// MARK: - Equatable, Hashable

extension DeviceEvent: Equatable, Hashable {
    public static func == (lhs: DeviceEvent, rhs: DeviceEvent) -> Bool {
        lhs.code == rhs.code &&
        lhs.timestamp == rhs.timestamp &&
        lhs.transactionID == rhs.transactionID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(timestamp)
        hasher.combine(transactionID)
    }
}

// MARK: - CustomStringConvertible

extension DeviceEvent: CustomStringConvertible {
    public var description: String {
        let type = isSolicited ? "solicited(txn:\(transactionID!))" : "unsolicited"
        let payloadDesc = payload.map { " payload:\($0.prefix(50))" } ?? ""
        return "DeviceEvent(code:\(code) \(type)\(payloadDesc))"
    }
}

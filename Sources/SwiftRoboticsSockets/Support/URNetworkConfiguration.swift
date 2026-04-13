/// Network configuration constants for Universal Robot socket connections.
///
/// All UR robot port numbers are defined here to avoid magic literals scattered
/// across handlers. Use these when constructing sockets or writing tests.
public enum URNetworkConfiguration {

    /// Port for the UR robot command server (inbound connection from robot). Default: 50001.
    public static let commandPort: Int = 50001

    /// Port for the UR robot stream server (inbound connection from robot). Default: 50002.
    public static let streamPort: Int = 50002

    /// Port for the UR robot primary/URScript interface (outbound client). Default: 30001.
    public static let scriptPort: Int = 30001

    /// Port for the UR robot dashboard server (outbound client). Default: 29999.
    public static let dashboardPort: Int = 29999

    /// Maximum transaction ID before wrapping back to 1. UR protocol supports IDs 1–899.
    public static let maxTransactionID: Int = 899
}

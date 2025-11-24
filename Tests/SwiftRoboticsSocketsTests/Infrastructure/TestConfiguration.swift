import Foundation

/// Configuration for robot testing
/// Users can manually set these values based on their test environment
public struct TestConfiguration {

    // MARK: - Host Configuration

    /// The IP address of the host machine for robot callbacks
    ///
    /// **For Docker Desktop (macOS/Windows):** Use "host.docker.internal" - no firewall issues!
    /// **For Docker on Linux:** Use "172.17.0.1" (Docker bridge) or host IP
    /// **For real robot on network:** Use your machine's network IP (e.g., "192.168.1.109")
    ///
    /// The robot inside Docker needs to connect BACK to the host machine.
    /// Docker provides special hostnames for this purpose.
    public static var hostCallbackIP: String {
        // Default to Docker Desktop's host gateway (macOS/Windows - no firewall prompts!)
        return "host.docker.internal"

        // For Docker on Linux, use Docker bridge IP:
        // return "172.17.0.1"

        // For real robot testing, use your machine's network IP (requires firewall exception):
        // return "192.168.1.109"

        // Or auto-detect (may trigger firewall prompts):
        // return (try? NetworkUtilities.getLocalIPAddress()) ?? "host.docker.internal"
    }

    // MARK: - Robot Configuration

    /// The IP address where the robot (or URSim) is accessible
    /// Default is "localhost" when using Docker with port forwarding
    public static let robotIP: String = "localhost"

    // MARK: - Port Configuration

    /// Dashboard server port (URSim default: 29999)
    public static let dashboardPort: Int = 29999

    /// URScript primary port (URSim default: 30001)
    public static let urScriptPort: Int = 30001

    /// Command and control server port (custom: 50001)
    public static let commandPort: Int = 50001

    /// Streaming server port (custom: 50002)
    public static let streamingPort: Int = 50002

    // MARK: - Timeout Configuration

    /// Default timeout for socket connections
    public static let connectionTimeout: TimeInterval = 10.0

    /// Default timeout for command responses
    public static let commandTimeout: TimeInterval = 5.0

    /// Default timeout for streaming operations
    public static let streamingTimeout: TimeInterval = 30.0

    /// Default timeout for robot movements (home, etc.)
    public static let movementTimeout: TimeInterval = 15.0

    // MARK: - Test Data Configuration

    /// The default waveform resource for streaming tests
    public static let defaultWaveformResource: String = "streamRotateBase"

    /// The number of poses per batch for streaming tests
    public static let defaultPosesPerBatch: Int = 5

    // MARK: - Helper Methods

    /// Prints the current test configuration
    public static func printConfiguration() {
        print("""

        Test Configuration:
        ------------------
        Host Callback IP:  \(hostCallbackIP)
        Robot IP:          \(robotIP)
        Dashboard Port:    \(dashboardPort)
        URScript Port:     \(urScriptPort)
        Command Port:      \(commandPort)
        Streaming Port:    \(streamingPort)

        Timeouts:
        ---------
        Connection:        \(connectionTimeout)s
        Command:           \(commandTimeout)s
        Streaming:         \(streamingTimeout)s
        Movement:          \(movementTimeout)s

        """)
    }
}

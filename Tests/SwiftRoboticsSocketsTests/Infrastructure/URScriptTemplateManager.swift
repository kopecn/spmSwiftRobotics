import Foundation
@testable import SwiftRoboticAssets

/// Manages URScript templates with dynamic host IP replacement for testing
public struct URScriptTemplateManager {

    // MARK: - Constants

    public static let hostIPPlaceholder = "<<HOST_CALLBACK_IPADDRESS>>"

    // MARK: - Template Loading

    /// Loads the urScript template from assets
    /// - Returns: The raw urScript content with placeholder
    /// - Throws: Error if template cannot be loaded
    public static func loadTemplate() throws -> String {
        guard let script = AssetLoader.loadURScript() else {
            throw URScriptError.templateNotFound
        }

        // Verify placeholder exists
        guard script.contains(hostIPPlaceholder) else {
            throw URScriptError.placeholderNotFound
        }

        return script
    }

    // MARK: - IP Replacement

    /// Replaces the host IP placeholder with an actual IP address
    /// - Parameters:
    ///   - script: The urScript content containing the placeholder
    ///   - ip: The IP address to insert
    /// - Returns: The script with IP address replaced
    public static func replaceHostIP(in script: String, with ip: String) -> String {
        return script.replacingOccurrences(of: hostIPPlaceholder, with: ip)
    }

    /// Gets the host machine's IP address automatically
    /// - Returns: The local IP address (e.g., "192.168.1.100")
    /// - Throws: Error if IP cannot be determined
    public static func getHostIPAddress() throws -> String {
        return try NetworkUtilities.getLocalIPAddress()
    }

    // MARK: - Convenience Methods

    /// Prepares a complete urScript for testing with IP replacement
    /// - Parameter hostIP: Optional manual IP override. If nil, auto-detects host IP
    /// - Returns: The complete urScript ready to send to robot
    /// - Throws: Error if template loading or IP detection fails
    public static func prepareScriptForTest(hostIP: String? = nil) throws -> String {
        let template = try loadTemplate()
        let ipAddress = try hostIP ?? getHostIPAddress()
        return replaceHostIP(in: template, with: ipAddress)
    }

    /// Prepares urScript using the test configuration IP
    /// - Returns: The complete urScript with test configuration IP
    /// - Throws: Error if template loading fails
    public static func prepareScriptWithTestConfig() throws -> String {
        let template = try loadTemplate()
        return replaceHostIP(in: template, with: TestConfiguration.hostCallbackIP)
    }

    /// Validates that a script has been properly prepared (no placeholder remaining)
    /// - Parameter script: The script to validate
    /// - Returns: True if script is ready (no placeholder), false otherwise
    public static func isScriptPrepared(_ script: String) -> Bool {
        return !script.contains(hostIPPlaceholder)
    }
}

// MARK: - Errors

public enum URScriptError: Error, CustomStringConvertible {
    case templateNotFound
    case placeholderNotFound
    case invalidIPAddress

    public var description: String {
        switch self {
        case .templateNotFound:
            return "URScript template could not be loaded from assets"
        case .placeholderNotFound:
            return "URScript template does not contain the expected placeholder: \(URScriptTemplateManager.hostIPPlaceholder)"
        case .invalidIPAddress:
            return "Invalid IP address provided for replacement"
        }
    }
}

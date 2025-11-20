import Foundation

/// Errors that can occur when loading assets
public enum AssetLoaderError: Error {
    case resourceNotFound(name: String, extension: String)
    case contentLoadingFailed(url: URL, underlying: Error)
    case decodingFailed(url: URL, underlying: Error)
}

/// Utility for loading assets from the module bundle
public enum AssetLoader {
    /// Returns the URL for a resource in the module bundle
    /// - Parameters:
    ///   - name: The name of the resource file
    ///   - ext: The file extension of the resource
    /// - Returns: The URL of the resource, or nil if not found
    public static func url(forResource name: String, withExtension ext: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: ext)
    }

    /// Loads a string resource from the module bundle
    /// - Parameters:
    ///   - name: The name of the resource file
    ///   - ext: The file extension of the resource
    /// - Returns: The string content of the resource, or nil if not found or loading fails
    public static func string(forResource name: String, withExtension ext: String) -> String? {
        guard let url = url(forResource: name, withExtension: ext),
            let content = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }
        return content
    }

    /// Loads a string resource from the module bundle with error handling
    /// - Parameters:
    ///   - name: The name of the resource file
    ///   - ext: The file extension of the resource
    /// - Returns: The string content of the resource
    /// - Throws: AssetLoaderError if the resource is not found or loading fails
    public static func stringWithError(
        forResource name: String,
        withExtension ext: String
    ) throws
        -> String
    {
        guard let url = url(forResource: name, withExtension: ext) else {
            throw AssetLoaderError.resourceNotFound(name: name, extension: ext)
        }

        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw AssetLoaderError.contentLoadingFailed(url: url, underlying: error)
        }
    }

    /// Loads raw data from a resource in the module bundle
    /// - Parameters:
    ///   - name: The name of the resource file
    ///   - ext: The file extension of the resource
    /// - Returns: The data content of the resource, or nil if not found or loading fails
    public static func data(forResource name: String, withExtension ext: String) -> Data? {
        guard let url = url(forResource: name, withExtension: ext) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    /// Loads the UR script resource
    /// - Returns: The content of the urScript.script file, or nil if not found or loading fails
    public static func loadURScript() -> String? {
        string(forResource: "urScript", withExtension: "script")
    }

    /// Loads and decodes a JSON resource into a Codable type
    /// - Parameters:
    ///   - name: The name of the resource file
    ///   - type: The type to decode the JSON into (must conform to Codable)
    /// - Returns: The decoded object, or nil if loading or decoding fails
    public static func loadJSON<T: Codable>(forResource name: String, as type: T.Type) -> T? {
        guard let data = data(forResource: name, withExtension: "json") else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Loads and decodes a JSON resource into a Codable type with error handling
    /// - Parameters:
    ///   - name: The name of the resource file
    ///   - type: The type to decode the JSON into (must conform to Codable)
    /// - Returns: The decoded object
    /// - Throws: AssetLoaderError if the resource is not found, loading fails, or decoding fails
    public static func loadJSONWithError<T: Codable>(
        forResource name: String,
        as type: T.Type
    ) throws -> T {
        guard let url = url(forResource: name, withExtension: "json") else {
            throw AssetLoaderError.resourceNotFound(name: name, extension: "json")
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw AssetLoaderError.contentLoadingFailed(url: url, underlying: error)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AssetLoaderError.decodingFailed(url: url, underlying: error)
        }
    }
}

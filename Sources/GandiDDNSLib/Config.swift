import Foundation

public enum RecordType: String, Codable {
    case A
    case AAAA
}

public struct Config: Codable {
    let domains: [Gandi.Domain]
}

public class ConfigReader {

    /// Data will be read and saved from here
    public let filename: String

    private static let defaultFilename = "config.json"

    /// Creates a new instance associated to a json file (by default, config.json).
    /// - parameter specificFile: Optionally, we can specify a json file name to be used instead of the default config.json
    public init(specificFile: String? = nil) {
        if let file = specificFile {
            filename = file
        } else {
            filename = ConfigReader.defaultFilename
        }
    }
    
    /// Reads config from a file. Returns nil if the file doesn't exist.
    /// First looks in directory where executable is found, then current dir.
    /// If a read failure happens (e.g. wrong format of json) throws error.
    public func read() throws -> Config? {
        guard let url = urlForReading(filename: filename) else {
            return nil
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let config = try decoder.decode(Config.self, from: data)
        return config
    }

    /// Saves inputted config to file.
    /// - throws Gandi.Error.zoneNotFound if there is something wrong with the domain (e.g. wrong key)
    public func saveConfig(withDomain: String, key: String) throws {
        let s1 = Gandi.Subdomain(name: "www", type: .A, ip: nil)
        let s2 = Gandi.Subdomain(name: "@", type: .A, ip: nil)
        let s3 = Gandi.Subdomain(name: "ipv6", type: .AAAA, ip: nil)
        let d1 = Gandi.Domain(name: withDomain, apiKey: key, subdomains: [s1, s2, s3])
        let config = Config(domains: [d1])

        // Test configuration before encoding it
        let _ = try Gandi(domain: d1)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(config)
    
        let url = URL(fileURLWithPath: filename)
        
        try data.write(to: url)

    }

    /// Returns the URL for the specified config filename.
    /// First checks in the directory of the executable,
    /// then in the current directory. Returns nil if the file
    /// couldn't be found.
    private func urlForReading(filename: String) -> URL? {
        var url: URL?
        let env = ProcessInfo.processInfo.environment
        if let uscore = env["_"] {
            let execDir = URL(fileURLWithPath: uscore).deletingLastPathComponent()
            let execDirJson = execDir.appendingPathComponent(filename)
            if let reachable = try? execDirJson.checkResourceIsReachable(), reachable {
                url = execDirJson
            }
        }
        
        if url == nil && FileManager.default.isReadableFile(atPath: filename) {
            url = URL(fileURLWithPath: filename)
        }

        return url
    }
}

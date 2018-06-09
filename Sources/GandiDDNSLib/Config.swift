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
    /// If a read failure happens (e.g. wrong format of json) throws error.
    public func read() throws -> Config? {
        guard FileManager.default.isReadableFile(atPath: filename) else {
            return nil
        }

        let url: URL = URL(fileURLWithPath: filename)
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
}
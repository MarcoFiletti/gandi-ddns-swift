import Foundation
import CommandLineParser
import GandiDDNSLib

/// Help that is printed when we input the wrong options
let usage = """
    Usage: GandiDDNS [options] [config]

    Options:
        -n Dry run:
        -v Verbose:
        -s Silent:

    Example:
        GandiDDNS -nv config2
        Will read from config2.json

    The first time run, creates config asking for Gandi API details and saves them
    in config.json (or the given config file specified as a parameter)
    """

/// Command line options
struct Options: CommandLineOptions {
    let rawValue: Int
    static let dry_run = Options(rawValue: 1 << 0)
    static let verbose = Options(rawValue: 1 << 1)
    static let silent = Options(rawValue: 1 << 2)
    
    static let correspondingFlags = "nvs"
}

/// Asks config from user and saves it, then quits.
/// If this is not an interactive terminal, exits with error 1.
func askForConfigAndQuit(_ reader: ConfigReader) {
    guard ProcessInfo.processInfo.environment["TERM"] != nil else {
        print("No config present and this is not an interactive terminal, qutting.")
        exit(1)
    }

    print(reader.filename + " not found, please provide Gandi API access details")
    print("")
    print("Domain name: >", terminator: "")
    guard let domainData = readLine()?.data(using: .utf8) else {
        exit(5)
    }
    print("API Key: >", terminator: "")
    guard let keyData = readLine()?.data(using: .utf8) else {
        exit(6)
    }
    guard let domainName = String(data: domainData, encoding: .utf8),
          let key = String(data: keyData, encoding: .utf8) else {
            print("Failed to convert data")
            exit(10)
    }

    do {
        try reader.saveConfig(withDomain: domainName, key: key)
        print("""
              Data saved into \(reader.filename).
              Optionally edit the file and run again to apply settings to Gandi.
              """)
        exit(0)
    } catch Gandi.Error.notAuthorized {
        print("Inserted key was rejected. Quitting.")
        exit(20)
    } catch Gandi.Error.zoneNotFound {
        print("Domain name could not be found. Quitting.")
        exit(30)
    } catch {
        print("Failed to save '\(reader.filename)' to disk.")
        exit(40)
    }
}

/// Reads config from file, or asks user for it and saves it, then quits
func readConfigOrQuit(_ reader: ConfigReader) -> Config {
    let maybeConfig = try! reader.read()
    if let config = maybeConfig {
        return config
    } else {
        askForConfigAndQuit(reader)
        fatalError("We should never get here")
    }
}

var dry_run = false
var optionalFile: String?
/// If we have any arguments check if they start with '-'
/// If an argument was not recognised, print help
do {
    if let (arguments, options, _) = try CommandLineParser<Options, Options>.parse(CommandLine.arguments) {
        
        // set verbose
        if options.contains(.verbose) {
            Log.level = .verbose
            Log.print("Verbose mode on", .verbose)
        } else if options.contains(.silent) {
            Log.level = .silent
        }

        // set dry run
        dry_run = options.contains(.dry_run)

        // if a json file is specified, use it instead of default
        if let fname = arguments.first {
            if fname.hasSuffix(".json") {
                optionalFile = fname
            } else {
                optionalFile = fname + ".json"
            }
            Log.print("Reading config from \(optionalFile!)")
        }
    }
} catch {
    print(usage)
    exit(1)
}

let reader = ConfigReader(specificFile: optionalFile)
let config = readConfigOrQuit(reader)

Gandi.apply(config: config, dry_run: dry_run)

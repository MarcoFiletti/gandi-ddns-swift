import Foundation
import GandiDDNSLib

/// Asks config from user and saves it, then quits
func askForConfigAndQuit() {
    print("Please input details")
    print("Domain name: >", terminator: "")
    guard let domainData = readLine()?.data(using: .utf8) else {
        print("Failed")
        exit(1)
    }
    print("API Key: >", terminator: "")
    guard let keyData = readLine()?.data(using: .utf8) else {
        print("Failed")
        exit(1)
    }
    guard let domainName = String(data: domainData, encoding: .utf8),
          let key = String(data: keyData, encoding: .utf8) else {
            print("Failed to convert data")
            exit(1)
    }

    do {
        try ConfigReader.saveConfig(withDomain: domainName, key: key)
        print("Data saved, quitting")
        exit(0)
    } catch Gandi.Error.notAuthorized {
        print("Your key is wrong")
        exit(10)
    } catch Gandi.Error.zoneNotFound {
        print("Domain could not be found")
        exit(20)
    } catch {
        print("Failed to save data")
        exit(30)
    }
}

/// Reads config from file, or asks user for it and saves it, then quits
func readConfigOrQuit() -> Config {
    let maybeConfig = try! ConfigReader.read()
    if let config = maybeConfig {
        return config
    } else {
        askForConfigAndQuit()
        fatalError("We should never get here")
    }
}

var dry_run = false
/// If we have any arguments check if they start with '-'
/// If an argument was not recognised, print help
if CommandLine.arguments.count > 1 {
    for i in 1..<CommandLine.arguments.count {
        let arg = CommandLine.arguments[i]
        if arg.first == "-" {
            if arg.contains("s") {
                Log.level = .silent
            } else if arg.contains("v") {
                Log.level = .verbose
                Log.print("Verbose mode on", .verbose)
            }
            if arg.contains("n") {
                dry_run = true
            }
        } else {
            print("Usage...")
            exit(1)
        }
    }
}

if dry_run == false {
    fatalError("better do a dry run for now")
}

let config = readConfigOrQuit()
Gandi.apply(config: config, dry_run: dry_run)

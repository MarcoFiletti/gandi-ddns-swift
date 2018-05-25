import Foundation
import GandiDDNSLib

func readGandiKey() {
    let keyname = "GandiAPI.key"
    let url: URL = URL(fileURLWithPath: keyname)
    if let data = try? Data(contentsOf: url),
       let key = String(data: data, encoding: .utf8) {
        print("Key is: \"\(key)\"")
    } else {
        print("Key in key: >", terminator: "")
        if let input = readLine(), let data = input.data(using: .utf8) {
            do {
                try data.write(to: url)
                print("Saved key")
            } catch {
                print("Failed to save key")
            }
        }
    }
}

func testGandi(dry_run: Bool) {

    if dry_run == false {
        print("better do a dry run for now")
    }

    let config = ConfigReader.default
    Gandi.apply(config: config, dry_run: dry_run)
// let g1 = try! GandiWrapper(domain: d1)
// try! g1.getIp(subdomain: "www", type: .A)
// try! g1.getIp(subdomain: "www", type: .AAAA)
// try! g1.getIp(subdomain: "vaff", type: .A)
//  g1.updateIp(subdomain: "testplay", type: .A, newIp: "85.216.202.141")

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

testGandi(dry_run: dry_run)

// readGandiKey()
func testRead() {
    if CommandLine.arguments.count == 2 {
        let fname = CommandLine.arguments[1]
        
        let url: URL = URL(fileURLWithPath: fname)

        guard let data = try? Data(contentsOf: url) else {
            print("Could read data from '\(fname)'")
            exit(2)
        }
        let dec = JSONDecoder()
        guard let ajson = try? dec.decode(Ajson.self, from: data) else {
            print("Failed to convert data in '\(fname)'")
            exit(2)
        }
        print("A is \(ajson.a)")
        
        if let IPv4String = IPFetcher.getIPv4() {
            print("IPv4 is: '\(IPv4String)'")
        } else {
            print("Failed to get IP")
        }
        
        if let IPv6String = IPFetcher.getIPv6() {
            print("IPv6 is: '\(IPv6String)'")
        }
        
    } else {
        print("No args, saving data: \(Test.sav())")
    }
}

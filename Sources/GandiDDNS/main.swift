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

func testGandi() {

    let config = ConfigReader.default
    Log.level = .verbose
    Gandi.apply(config: config, dry_run: true)
// let g1 = try! GandiWrapper(domain: d1)
// try! g1.getIp(subdomain: "www", type: .A)
// try! g1.getIp(subdomain: "www", type: .AAAA)
// try! g1.getIp(subdomain: "vaff", type: .A)
//  g1.updateIp(subdomain: "testplay", type: .A, newIp: "85.216.202.141")

}

testGandi()

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

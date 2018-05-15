import Foundation

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
    
    if let ipString = IPFetcher.getIP() {
        print("IP is: \(ipString)")
    } else {
        print("Failed to get IP")
    }
    
} else {
    print("No args, saving data: \(Test.sav())")
}

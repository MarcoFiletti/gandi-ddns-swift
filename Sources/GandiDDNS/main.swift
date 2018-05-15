import Foundation

if CommandLine.arguments.count == 2 {
    let fname = CommandLine.arguments[1]
    
    let url: URL = URL(fileURLWithPath: fname)
    
    guard let data = try? Data(contentsOf: url) else {
        throw NSError(domain: "Could read data from '\(fname)'", code: 1)
    }
    let dec = JSONDecoder()
    guard let ajson = try? dec.decode(Ajson.self, from: data) else {
        throw NSError(domain: "Failed to convert data in '\(fname)'", code: 2)
    }
    print("A is \(ajson.a)")
    
    let ses = URLSession.shared
    guard let ipUrl = URL(string: "https://api.ipify.org") else {
        throw NSError(domain: "Failed to get ip", code: 3)
    }
    
    let group = DispatchGroup()
    
    group.enter()
    ses.dataTask(with: ipUrl) {
        data, response, error in
        
        if let data = data, let ipString = String(data: data, encoding: .utf8) {
            print("IP is: \(ipString)")
        } else {
            print("No IP String got")
        }
        
        group.leave()
    }.resume()
    
    if group.wait(timeout: DispatchTime.now() + 3.0) == .timedOut {
        throw NSError(domain: "Failed to get ip: timeout", code: 4)
    }
} else {
    print("No args, saving data: \(Test.sav())")
}

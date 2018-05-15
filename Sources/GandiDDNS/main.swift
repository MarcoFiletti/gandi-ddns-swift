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
    
    let ses = URLSession.shared
    guard let ipUrl = URL(string: "https://api.ipify.org") else {
        print("Failed to get ip url")
        exit(2)
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
        print("Failed to get ip: timeout")
        exit(2)
    }
} else {
    print("No args, saving data: \(Test.sav())")
}

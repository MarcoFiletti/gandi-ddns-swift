import Foundation

if CommandLine.arguments.count == 2 {
    let fname = CommandLine.arguments[1]
    
    let url: URL = URL(fileURLWithPath: fname)
    
    guard let data = try? Data(contentsOf: url) else {
        throw NSError(domain: "Could read data from '\(fname)': error.localizedDescription", code: 1)
    }
    let dec = JSONDecoder()
    guard let ajson = try? dec.decode(Ajson.self, from: data) else {
        throw NSError(domain: "Failed to convert data in '\(fname)' to JSON: error.localizedDescription", code: 2)
    }
    print("A is \(ajson.a)")
} else {
    print("No args, saving data: \(Test.sav())")
}

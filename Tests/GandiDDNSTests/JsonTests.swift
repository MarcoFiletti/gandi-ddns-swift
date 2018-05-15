import XCTest
@testable import GandiDDNSLib

class JsonTests: XCTestCase {

    func testOne() {
        let a = Ajson()
        XCTAssert(a.a == "one", "A should be one")
    }
    
}

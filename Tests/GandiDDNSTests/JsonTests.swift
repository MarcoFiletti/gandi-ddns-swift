import XCTest

class JsonTests: XCTestCase {

    func testOne() {
        XCTAssertEqual(1, 1);
    }
    
    func testTwo() {
        XCTAssertEqual(2, 2);
    }

	static var allTests = [
        ("test1", testOne),
        ("test2", testTwo),
    ]
}
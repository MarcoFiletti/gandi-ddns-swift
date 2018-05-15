import XCTest

extension JsonTests {
    static let __allTests = [
        ("testOne", testOne),
        ("testTwo", testTwo),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JsonTests.__allTests),
    ]
}
#endif

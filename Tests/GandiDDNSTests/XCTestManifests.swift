import XCTest

extension IPTests {
    static let __allTests = [
        ("testIPv4", testIPv4),
        ("testIPv6", testIPv6),
    ]
}

extension JsonTests {
    static let __allTests = [
        ("testOne", testOne),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(IPTests.__allTests),
        testCase(JsonTests.__allTests),
    ]
}
#endif

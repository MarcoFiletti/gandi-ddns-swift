import XCTest

extension ParserTests {
    static let __allTests = [
        ("testOnlyDashes", testOnlyDashes),
        ("testWithPluses", testWithPluses),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ParserTests.__allTests),
    ]
}
#endif

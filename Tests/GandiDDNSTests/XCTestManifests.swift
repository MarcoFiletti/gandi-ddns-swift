import XCTest

extension GandiTests {
    static let __allTests = [
        ("testAuthFailure", testAuthFailure),
        ("testDomainFailure", testDomainFailure),
        ("testWithDetails", testWithDetails),
    ]
}

extension IPTests {
    static let __allTests = [
        ("testIPv4", testIPv4),
        ("testIPv6", testIPv6),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GandiTests.__allTests),
        testCase(IPTests.__allTests),
    ]
}
#endif

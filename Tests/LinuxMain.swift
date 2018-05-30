import XCTest

import GandiDDNSTests
import CommandLineParserTests

var tests = [XCTestCaseEntry]()
tests += GandiDDNSTests.__allTests()
tests += CommandLineParserTests.__allTests()

XCTMain(tests)

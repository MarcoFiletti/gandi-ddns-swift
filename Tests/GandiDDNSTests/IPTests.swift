//
//  IPTests.swift
//  GandiDDNSTests
//
//  Created by Marco Filetti on 15/05/2018.
//

import XCTest
@testable import GandiDDNSLib

class IPTests: XCTestCase {

    func testIPv4() {
        guard let ip = IPFetcher.getIPv4() else {
            XCTFail("Couldn't get IPv4")
            return
        }

        XCTAssert(ip.count > 5, "IPv4 should be at least 5 characters long")

    }

    func testIPv6() {
        guard let ip = IPFetcher.getIPv6() else {
            XCTFail("Couldn't get IPv6")
            return
        }

        XCTAssert(ip.count > 14, "IPv6 should be at least 14 characters long")
    }

}

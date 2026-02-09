//
//  IPTests.swift
//  GandiDDNSTests
//
//  Created by Marco Filetti on 15/05/2018.
//

import Testing
@testable import GandiDDNSLib

@Test
func iPv4() {
    guard let ip = IPFetcher.getIPv4() else {
        Issue.record("Couldn't get IPv4")
        return
    }
    #expect(ip.count > 5, "IPv4 should be at least 5 characters long")
}

@Test
func iPv6() {
    guard let ip = IPFetcher.getIPv6() else {
        Issue.record("Couldn't get IPv6")
        return
    }
    #expect(ip.count > 14, "IPv6 should be at least 14 characters long")
}

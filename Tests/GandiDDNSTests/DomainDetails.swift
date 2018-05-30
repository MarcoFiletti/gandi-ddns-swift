//
//  DomainDetails.swift
//  GandiDDNSTests
//
//  Created by Marco Filetti on 30/05/2018.
//

import XCTest
@testable import GandiDDNSLib

/// This can contain the actual domain details, then the skip-worktree flag can be added in git so personal details
/// are not sent to a repo.
/// To set the skip worktree flag, in root of package run: ``
class DomainDetails {
    static let domainName = "example.com"
    static let apiKey = "changeme"
}

//
//  DomainDetails.swift
//  GandiDDNSTests
//
//  Created by Marco Filetti on 30/05/2018.
//

import XCTest
@testable import GandiDDNSLib

/// To test properly, this must contain the actual domain details.
/// The skip-worktree flag should be added in git so personal details
/// are not sent to a remote.
/// To set the skip worktree flag, in root of package run:
/// `git update-index --skip-worktree Tests/GandiDDNSTests/DomainDetails.swift`
class DomainDetails {
    static let domainName = "example.com"
    static let apiKey = "changeme"
}

//
//  UpdateResult.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 18.2.2026.
//

import Foundation

public struct UpdateResult: Sendable {

    let domain: Gandi.Domain
    let domainOutcome: DomainOutcome
    let outcomePerSubdomain: [(Gandi.Subdomain, SubdomainOutcome)]
    let dryRun: Bool
    
    public init(
        domain: Gandi.Domain,
        domainOutcome: DomainOutcome,
        outcomePerSubdomain: [(subdomain: Gandi.Subdomain, outcome: SubdomainOutcome)],
        dryRun: Bool
    ) {
        self.domain = domain
        self.domainOutcome = domainOutcome
        self.outcomePerSubdomain = outcomePerSubdomain
        self.dryRun = dryRun
    }
}

public extension UpdateResult {
    
    enum DomainOutcome: Sendable {
        case dryRun
        case success
        case zoneNotFound
        case error(String)
    }
    
    enum SubdomainOutcome: Sendable {
        case newIp(String)
        case error(Error)
    }
}

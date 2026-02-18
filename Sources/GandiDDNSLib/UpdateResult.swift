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
    
}

public extension UpdateResult {
    
    enum DomainOutcome: Sendable {
        case dryRun
        case sucess
        case zoneNotFound
        case error(String)
    }
    
    enum SubdomainOutcome: Sendable {
        case newIp(String)
        case error(Error)
    }
}

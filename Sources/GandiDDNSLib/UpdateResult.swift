//
//  UpdateResult.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 18.2.2026.
//

import Foundation

public struct UpdateResult: Sendable, CustomStringConvertible {

    let domain: Gandi.Domain
    let domainOutcome: DomainOutcome
    let outcomePerSubdomain: [(Gandi.Subdomain, SubdomainOutcome)]
    let dryRun: Bool
    
    public var description: String {
        let domainPart = "\(domain.name),outcome:\(domainOutcome.description)"
        let dryRunPart = "dryRun:" + (dryRun ? "true" : "false")
        let subdomainParts = outcomePerSubdomain.map { sub, outcome in
            "\(sub.name):\(sub.type.rawValue):\(sub.ip ?? ""):\(outcome.description)"
        }
        return ([domainPart, dryRunPart] + subdomainParts).joined(separator: ",")
    }
    
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

    enum DomainOutcome: Sendable, CustomStringConvertible {
        case dryRun
        case success
        case zoneNotFound
        case error(String)

        public var description: String {
            switch self {
            case .dryRun: return "dryRun"
            case .success: return "success"
            case .zoneNotFound: return "zoneNotFound"
            case .error(let message): return "error:\(message)"
            }
        }
    }

    enum SubdomainOutcome: Sendable, CustomStringConvertible {
        case newIp(String)
        case error(Error)

        public var description: String {
            switch self {
            case .newIp(let ip): return "newIp:\(ip)"
            case .error(let err): return "error:\(err.localizedDescription)"
            }
        }
    }
}

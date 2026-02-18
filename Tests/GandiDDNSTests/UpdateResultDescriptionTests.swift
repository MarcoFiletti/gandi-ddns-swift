import Foundation
import Testing
@testable import GandiDDNSLib

// MARK: - Helpers

private func makeDomain(name: String = "example.com", subdomains: [Gandi.Subdomain] = []) -> Gandi.Domain {
    Gandi.Domain(name: name, apiKey: "test-key", subdomains: subdomains)
}

private func makeSubdomain(name: String, type: RecordType = .A, ip: String? = nil) -> Gandi.Subdomain {
    Gandi.Subdomain(name: name, type: type, ip: ip)
}

// MARK: - DomainOutcome cases

@Test
func description_domainOutcome_dryRun() {
    let domain = makeDomain(name: "dry.example.com")
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .dryRun,
        outcomePerSubdomain: [],
        dryRun: true
    )
    #expect(result.description == "dry.example.com:dryRun,true")
}

@Test
func description_domainOutcome_success() {
    let domain = makeDomain(name: "ok.example.com")
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .success,
        outcomePerSubdomain: [],
        dryRun: false
    )
    #expect(result.description == "ok.example.com:success,false")
}

@Test
func description_domainOutcome_zoneNotFound() {
    let domain = makeDomain(name: "missing.example.com")
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .zoneNotFound,
        outcomePerSubdomain: [],
        dryRun: false
    )
    #expect(result.description == "missing.example.com:zoneNotFound,false")
}

@Test
func description_domainOutcome_error() {
    let domain = makeDomain(name: "err.example.com")
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .error("API rate limit"),
        outcomePerSubdomain: [],
        dryRun: false
    )
    #expect(result.description == "err.example.com:error:API rate limit,false")
}

// MARK: - SubdomainOutcome cases

@Test
func description_oneSubdomain_newIp() {
    let sub = makeSubdomain(name: "www", type: .A, ip: "192.168.1.1")
    let domain = makeDomain(name: "example.com", subdomains: [sub])
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .success,
        outcomePerSubdomain: [(sub, .newIp("192.168.1.1"))],
        dryRun: false
    )
    #expect(result.description == "example.com:success,false,www:A:192.168.1.1:newIp:192.168.1.1")
}

@Test
func description_oneSubdomain_error() {
    let sub = makeSubdomain(name: "api", type: .AAAA, ip: nil)
    let domain = makeDomain(name: "example.com", subdomains: [sub])
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .success,
        outcomePerSubdomain: [(sub, .error(TestError.dnsFailed))],
        dryRun: false
    )
    #expect(result.description == "example.com:success,false,api:AAAA::error:DNS update failed")
}

@Test
func description_subdomain_nilIp_rendersEmptyBetweenColons() {
    let sub = makeSubdomain(name: "ftp", type: .A, ip: nil)
    let domain = makeDomain(name: "example.com", subdomains: [sub])
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .success,
        outcomePerSubdomain: [(sub, .newIp("10.0.0.1"))],
        dryRun: false
    )
    // Subdomain ip is nil so we get "ftp:A::newIp:10.0.0.1" (empty between colons)
    #expect(result.description == "example.com:success,false,ftp:A::newIp:10.0.0.1")
}

@Test
func description_multipleSubdomains_mixedOutcomes() {
    let sub1 = makeSubdomain(name: "www", type: .A, ip: "1.2.3.4")
    let sub2 = makeSubdomain(name: "mail", type: .AAAA, ip: "::1")
    let domain = makeDomain(name: "multi.example.com", subdomains: [sub1, sub2])
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .success,
        outcomePerSubdomain: [
            (sub1, .newIp("1.2.3.4")),
            (sub2, .error(TestError.dnsFailed)),
        ],
        dryRun: true
    )
    // Format: domain:outcome,dryRun,sub1Part,sub2Part. Sub part = name:type:ip:outcome.
    // Note: IPv6 "::1" yields ":::" in the middle (mail:AAAA:::1:error:...) due to colons in the address.
    let expected = "multi.example.com:success,true,www:A:1.2.3.4:newIp:1.2.3.4,mail:AAAA:::1:error:DNS update failed"
    #expect(result.description == expected)
}

@Test
func description_isSingleLine_withCommaAndColonSeparators() {
    let sub = makeSubdomain(name: "a", type: .A, ip: "1.1.1.1")
    let domain = makeDomain(name: "line.example.com", subdomains: [sub])
    let result = UpdateResult(
        domain: domain,
        domainOutcome: .success,
        outcomePerSubdomain: [(sub, .newIp("1.1.1.1"))],
        dryRun: false
    )
    #expect(!result.description.contains("\n"))
    let parts = result.description.split(separator: ",")
    #expect(parts.count >= 3) // domainPart, dryRunPart, and at least one subdomain part
    #expect(parts[0].contains(":")) // domain:outcome
    #expect(parts[2].contains(":"))  // subdomain fields and outcome use colons; main parts separated by commas
}

// MARK: - Test error for SubdomainOutcome.error

private enum TestError: Error {
    case dnsFailed
}

extension TestError: CustomStringConvertible {
    var description: String { "DNS update failed" }
}

extension TestError: LocalizedError {
    var errorDescription: String? { description }
}

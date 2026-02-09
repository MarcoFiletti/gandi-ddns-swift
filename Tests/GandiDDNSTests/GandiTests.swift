import Testing
@testable import GandiDDNSLib

/// Test using actual domain details. Edit the DomainDetails.swift file (after setting the skip-worktree git flag on it) the run this test.
/// To set the skip worktree flag, in root of package run:
/// `git update-index --skip-worktree Tests/GandiDDNSTests/DomainDetails.swift`
@Test
func withDetails() throws {
    let subdomain = Gandi.Subdomain(name: "www", type: .A, ip: nil)

    if DomainDetails.domainName == "example.com" {
        Issue.record("The DomainDetails.swift file should point to an actual domain in order to test the API calls")
        return
    }

    let domain = Gandi.Domain(name: DomainDetails.domainName, apiKey: DomainDetails.apiKey, subdomains: [subdomain])

    let g1 = try Gandi(domain: domain)
    g1.dry_run = true

    let x = try g1.getIp(subdomainName: "www", type: .A)
    #expect(x != nil, "First request should be valid (if we support IPv4)")
    let y = try g1.getIp(subdomainName: "www", type: .AAAA)
    #expect(y != nil, "Second request should be valid (if we support IPv6)")
    let z = try g1.getIp(subdomainName: "nothingtoseehere", type: .A)
    #expect(z == nil, "Third request should be nil (subdomain should not exist)")

    try g1.updateAllSubdomains()
}

@Test
func authFailure() {
    do {
        let _ = try Gandi(domain: Gandi.Domain(name: "example.nothing", apiKey: "nokey", subdomains: []))
        #expect(Bool(false), "An exception should be thrown")
    } catch let error as Gandi.Error {
        #expect(error == .forbidden || error == .unauthorized, "Expected forbidden or unauthorized, got \(error)")
    } catch {
        #expect(Bool(false), "The error should be not authorized or forbidden, instead it was \(error)")
    }
}

@Test
func domainFailure() {
    do {
        let _ = try Gandi(domain: Gandi.Domain(name: "example.nothing", apiKey: DomainDetails.apiKey, subdomains: []))
        #expect(Bool(false), "An exception should be thrown")
    } catch let error as Gandi.Error {
        #expect(error == .zoneNotFound, "Expected zoneNotFound, got \(error)")
    } catch {
        #expect(Bool(false), "The error should be zone not found")
    }
}

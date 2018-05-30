import XCTest
@testable import GandiDDNSLib

class GandiTests: XCTestCase {

    /// Test using actual domain details. Edit the DomainDetails.swift file (after setting the skip-worktree git flag on it) the run this test.
    /// To set the skip worktree flag, in root of package run: ``
    func testWithDetails() {
        
        let subdomain = Gandi.Subdomain(name: "www", type: .A, ip: nil)
        let domain = Gandi.Domain(name: DomainDetails.domainName, apiKey: DomainDetails.apiKey, subdomains: [subdomain])
        
        do {

            let g1 = try Gandi(domain: domain)
            g1.dry_run = true

            let x = try g1.getIp(subdomain: "www", type: .A)
            XCTAssertNotNil(x, "First request should be valid (if we support IPv4")
            let y = try g1.getIp(subdomain: "www", type: .AAAA)
            XCTAssertNotNil(y, "Second request should be valid (if we support IPv6")
            let z = try g1.getIp(subdomain: "nothingtoseehere", type: .A)
            XCTAssertNil(z, "Third request should be nil (subdomain should not exist")
            
            try g1.updateAllSubdomains()
            
        } catch {
            XCTFail("No exceptions were expected")
        }
    }
    
}

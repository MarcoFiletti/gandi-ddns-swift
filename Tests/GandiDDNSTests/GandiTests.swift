import XCTest
@testable import GandiDDNSLib

class GandiTests: XCTestCase {

    /// Test using actual domain details. Edit the DomainDetails.swift file (after setting the skip-worktree git flag on it) the run this test.
    /// To set the skip worktree flag, in root of package run:
    /// `git update-index --skip-worktree Tests/GandiDDNSTests/DomainDetails.swift`
    func testWithDetails() {
        
        let subdomain = Gandi.Subdomain(name: "www", type: .A, ip: nil)

        if DomainDetails.domainName == "example.com" {
            fatalError("The DomainDetails.swift file should point to an actual domain in order to test the API calls")
        }

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
    
    func testAuthFailure() {
        do {
            let _ = try Gandi(domain: Gandi.Domain(name: "example.nothing", apiKey: "nokey", subdomains: []))
            XCTFail("An exception should be thrown")
        } catch Gandi.Error.notAuthorized {
            // this is expected
        } catch {
            XCTFail("The error not found sould be not authorized")
        }
    }
    
    func testDomainFailure() {
        do {
            let _ = try Gandi(domain: Gandi.Domain(name: "example.nothing", apiKey: DomainDetails.apiKey, subdomains: []))
            XCTFail("An exception should be thrown")
        } catch Gandi.Error.zoneNotFound {
            // this is expected
        } catch {
            XCTFail("The error not found sould be zone not found")
        }
    }
    
}

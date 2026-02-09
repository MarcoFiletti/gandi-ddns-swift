import Foundation

/// Wraps communication with Gandi
public class Gandi {

    /// Runs the given configuration
    public static func apply(config: Config, dry_run: Bool = false) {
        for domain in config.domains {
            let instance: Gandi
            do {
                instance = try Gandi(domain: domain)
                Log.print("\nRunning: \(domain.name)", .verbose)
                if dry_run {
                    Log.print("Note: dry run, DNS records will not actually be modified for \(domain.name)")
                    instance.dry_run = dry_run
                }
            } catch {
                Log.print("Failed to find zone for domain \(domain.name)")
                continue
            }
            do {
                try instance.updateAllSubdomains()
            } catch {
                Log.print("Failed to update domain \(domain.name)")
            }
        }
    }

    /// Set this to true if we don't want to send any POST or PUT requests to Gandi
    /// Useful to test with high verbosity without changing DNS records
    public var dry_run = false
    
    public enum Error: Swift.Error {
        /// An unexpected error occurred
        case unexpectedResponse
        /// This indicates that API Key is wrong
        case unauthorized
        /// This indicates that the user cannot access the given resource
        case forbidden
        /// This indicates that domain was wrong
        case zoneNotFound
        /// Something was not found (in general)
        case notFound
        /// One or more subDomains failed to update
        case subError
    }

    public struct Domain: Codable {
        let name: String
        let apiKey: String
        let subdomains: [Gandi.Subdomain]
    }

    public struct Subdomain: Codable {
        let name: String
        let type: RecordType
        let ip: String?
    }

    public let domain: Gandi.Domain
    public let baseUrl: String
    
    /// Default zone. Initialized if domain exists and key is correct.
    /// Always gets overwritten when requesting zone.
    public var zone: Zone?
    
    /// Throws zoneNotFound if zone fetch failed (e.g. wrong key).
    public init(domain: Gandi.Domain) throws {
        self.domain = domain
        self.baseUrl = "https://dns.api.gandi.net/api/v5/domains/" + domain.name
        
        do {
            let resp = try send(.getZone)
            if case let .zone(zoneResp) = resp {
                self.zone = zoneResp
            } else {
                throw Gandi.Error.unexpectedResponse
            }
        } catch Gandi.Error.notFound {
            throw Gandi.Error.zoneNotFound
        }
    }
    
    /// A DNS zone, as represented in Gandi's API
    public struct Zone: Codable {
        /// UUID of zone
        let zone_uuid: String
        /// Address pointing to zone (includes UUID in address)
        let zone_href: String
    }

    /// A DNS record, as represented in Gandi's API
    public struct Record: Codable {
        let rrset_name: String
        let rrset_type: String
        let rrset_ttl: Int
        var rrset_values: [String]
        
        /// Creates a new record (e.g. in case it didn't exist on Gandi)
        init(name: String, type: RecordType, value: String) {
            self.rrset_name = name
            self.rrset_type = type.rawValue
            self.rrset_values = [value]
            self.rrset_ttl = 10800
        }
        
        /// Updates record with new value (i.e. address)
        mutating func updateValue(newValue: String) {
            rrset_values = [newValue]
        }
    }
    
    /// The request we want to send to Gandi
    public enum Request {
        /// We request zone information
        case getZone
        /// We request record information for the given subdomain name (record name) and record type (make sure url points to zone href)
        case getRecord(String, RecordType)
        /// We want to add a record (make sure url points to zone href)
        case addRecord(Record)
        /// Change record to the given one (make sure url points to zone href)
        case updateRecord(Record)
    }

    /// A response from Gandi
    public enum Response {
        /// Gandi replied with a zone
        case zone(Zone)
        /// Gandi replied with a record
        case record(Record)
        /// Operation succeeded
        case success
    }

    /** Sends a request to gandi http://doc.livedns.gandi.net/#api-endpoint
     - parameter urlString: The Gandi api address for the domain of interest
     - parameter apiKey: The key granting access to the domain
     - parameter req: The type of request we want to submit
     - returns Gandi's response
     */
    public func send(_ req: Request) throws -> Response {
        let url: URL
        
        switch req {
        case .getZone:
            url = URL(string: baseUrl)!
        case .getRecord(let subdomain, let type):
            let urlString = zone!.zone_href
            url = URL(string: urlString + "/records/" + subdomain + "/" + type.rawValue)!
        case .addRecord:
            let urlString = zone!.zone_href
            url = URL(string: urlString + "/records")!
        case .updateRecord(let record):
            let urlString = zone!.zone_href
            url = URL(string: urlString + "/records/" + record.rrset_name + "/" + record.rrset_type)!
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(domain.apiKey, forHTTPHeaderField: "X-Api-Key")
        
        // set additional request parameters
        switch req {
        case .getZone, .getRecord:
            urlRequest.httpMethod = "GET"
        case .addRecord(let record):
            // if this is a dry run, don't do anything and assume success
            guard !dry_run else {
                return .success
            }
            
            urlRequest.httpMethod = "POST"
            let enc = JSONEncoder()
            if let data = try? enc.encode(record) {
                urlRequest.httpBody = data
            }
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .updateRecord(let record):
            // if this is a dry run, don't do anything and assume success
            guard !dry_run else {
                return .success
            }

            urlRequest.httpMethod = "PUT"
            let enc = JSONEncoder()
            if let data = try? enc.encode(record) {
                urlRequest.httpBody = data
            }
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        switch processRequest(urlRequest) {
        case .found(let response):
            return response
        case .failure(let code):
            switch code {
            case 404:
                throw Gandi.Error.notFound
            case 401:
                throw Gandi.Error.unauthorized
            case 403:
                throw Gandi.Error.forbidden
            default:
                throw Gandi.Error.unexpectedResponse
            }
        case .success:
            return .success
        }
    }
    
    /// Hides some asynchronous complexity in http requests away from clients
    private enum InnerResponse {
        // We found some data
        case found(Response)
        // Success that does not involve returning data
        case success
        // An error with http error code (-1 for timeout, -2 is programmer error)
        case failure(Int)
    }
    
    /// Wraps url request to make it synchronous
    private func processRequest(_ urlRequest: URLRequest) -> InnerResponse {
        
        var retVal = InnerResponse.failure(-2)
        
        let group = DispatchGroup()
        group.enter()
        URLSession.shared.dataTask(with: urlRequest) {
            data, response, _ in
            
            if let data = data {
                let decoder = JSONDecoder()
                
                if let z = try? decoder.decode(Zone.self, from: data) {
                    retVal = InnerResponse.found(Response.zone(z))
                } else if let r = try? decoder.decode(Record.self, from: data) {
                    retVal = InnerResponse.found(Response.record(r))
                } else if let r = response as? HTTPURLResponse, r.statusCode >= 200, r.statusCode < 300 {
                    // accept good status codes
                    retVal = .success
                } else if let r = response as? HTTPURLResponse {
                    retVal = .failure(r.statusCode)
                }
            }
            
            group.leave()
        }.resume()
        
        guard group.wait(timeout: .now() + 3) != .timedOut else {
            Log.print("Request to Gandi timed out")
            return InnerResponse.failure(-1)
        }
        
        return retVal
    }
    
    /// Returns ip, nil if subdomain was not found.
    /// - throws: `Gandi.Error.unexpectedResponse` if an error different than not found was returned.
    public func getIp(subdomainName: String, type: RecordType) throws -> String? {
        do {
            let resp = try send(.getRecord(subdomainName, type))
            switch resp {
            case .record(let foundRecord):
                // if we found a valid record, returns first value
                guard foundRecord.rrset_values.count > 0 else {
                    Log.print("Found an empty DNS record for subdomain \(subdomainName)")
                    throw Gandi.Error.unexpectedResponse
                }
                return foundRecord.rrset_values[0]
            default:
                throw Gandi.Error.unexpectedResponse
            }
        } catch Gandi.Error.notFound {
            return nil
        }
    }
    
    /// Updates the ip for the given record, if different. If the record doesn't exists, creates it.
    /// - throws: `Gandi.Error.unexpectedResponse` if an unexpected error took place (e.g. timeout)
    public func updateIp(_ subdomain: Subdomain, newIp: String) throws {
        let maybePreviousIp = try self.getIp(subdomainName: subdomain.name, type: subdomain.type)
        let newRecord = Record(name: subdomain.name, type: subdomain.type, value: newIp)
        if maybePreviousIp == nil {
            Log.print("Creating subdomain \(subdomain.name) in \(domain.name) pointing to \(newIp)")
            let _ = try send(.addRecord(newRecord))
        } else if let previousIp = maybePreviousIp {
            if previousIp != newIp {
                Log.print("Updating \(subdomain.name).\(domain.name) from \(previousIp) to \(newIp)")
                let _ = try send(.updateRecord(newRecord))
            } else {
                Log.print("Desired address already matches Gandi DNS value for \(subdomain.name).\(domain.name)", .verbose)
            }
        }
    }
    
    /// Updates all stored subdomains to use the given ip (if any)
    /// - throws: Gandi.Error.subError if one or more subdomains failed to update (still tries to update others)
    /// - throws: IPFetcher.Error.fetchError if the IP for current machine could not be fetched (terminates operation)
    public func updateAllSubdomains() throws {
        var foundError = false

        for subdomain in domain.subdomains {
            Log.print("Checking IP for subdomain \(subdomain.name) of type \(subdomain.type.rawValue)", .verbose)
            // if a desired ip is set use it, otherwise use ip for current machine
            let newIp: String = subdomain.ip != nil ? subdomain.ip! : try IPFetcher.getIP(forType: subdomain.type)
            do {
                try self.updateIp(subdomain, newIp: newIp)
            } catch {
                Log.print("Failed to update \(subdomain.type.rawValue) record for subdomain '\(subdomain.name)' with new ip '\(newIp)'")
                foundError = true
            }
        }

        if foundError { throw Gandi.Error.subError }
    }
}


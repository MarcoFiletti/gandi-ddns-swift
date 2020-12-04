//
//  IPFetcher.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 15/05/2018.
//

import Foundation
import FoundationNetworking

public class IPFetcher {

    /// IPv4 is cached here to prevent sending too many requests
    static var lastIPv4: String?

    /// IPv6 is cached here to prevent sending too many requests
    static var lastIPv6: String?

    public enum Error: Swift.Error {
        case fetchFail
    }

    /// Helper function to get the ip depending on record type.
    /// Uses cached values if present to avoid sending too many requests.
    /// - throws: IPFetcher.Error.fetchFail if the address could not be retrieved
    public static func getIP(forType: RecordType) throws -> String {
        let maybeAddress: String?
        switch forType {
        case .A:
            maybeAddress = lastIPv4 != nil ? lastIPv4! : getIPv4()
        case .AAAA:
            maybeAddress = lastIPv6 != nil ? lastIPv6! : getIPv6()
        }

        guard let foundAddress = maybeAddress else {
            throw IPFetcher.Error.fetchFail
        }

        Log.print("IP address of current machine for record type \(forType.rawValue) is \(foundAddress)", .verbose)
        return foundAddress
    }
    
    /// Returns a string containing IPv4 if successful, otherwise nil
    public static func getIPv4() -> String? {
        
        let ses = URLSession.shared
        guard let ipUrl = URL(string: "https://api.ipify.org") else {
            Log.print("Failed to create ip url")
            return nil
        }
        
        let group = DispatchGroup()
        var ipString: String? = nil
        
        group.enter()
        ses.dataTask(with: ipUrl) {
            data, response, error in
            
            if let data = data {
                ipString = String(data: data, encoding: .utf8)
            }
            
            group.leave()
            }.resume()
        
        guard group.wait(timeout: DispatchTime.now() + 3.0) != .timedOut else {
            Log.print("Ipify request failed, couldn't get IPv4")
            return nil
        }
        
        IPFetcher.lastIPv4 = ipString
        return ipString
    }
    
    /// Returns IPv6 using shell
    public static func getIPv6() -> String? {
        
        #if !os(macOS)
            guard let iface = Shell.run("ifconfig -s | awk '{ print $1 }' | grep en") else {
                return nil
            }
            let command = "ip addr show dev \(iface.trimmingCharacters(in: .whitespacesAndNewlines)) | sed -e's/^.*inet6 \\([^ ]*\\)\\/.*$/\\1/;t;d' | head -1"
        #else
            let command = "ifconfig en0 | grep inet6 | grep \"autoconf secured\" | awk -F \" \" '{print $2}' | head -1"
        #endif
        
        guard let shellRet = Shell.run(command) else {
            Log.print("Shell command to obtain IPv6 failed")
            return nil
        }
        
        let trimmed = shellRet.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 12 {
            IPFetcher.lastIPv6 = trimmed
            return trimmed
        } else {
            Log.print("Shell command to obtained IPv6 returned an unexpected result")
            return nil
        }

    }
}

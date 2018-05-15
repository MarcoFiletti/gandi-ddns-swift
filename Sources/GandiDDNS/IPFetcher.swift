//
//  IPFetcher.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 15/05/2018.
//

import Foundation

class IPFetcher {
    
    /// Returns a string containing IPv4 if successful, otherwise nil
    static func getIPv4() -> String? {
        
        let ses = URLSession.shared
        guard let ipUrl = URL(string: "https://api.ipify.org") else {
            print("Failed to get ip url")
            exit(2)
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
            return nil
        }
        
        return ipString
    }
    
    /// Returns IPv6 using shell
    static func getIPv6() -> String? {
        
        #if !os(macOS)
            let command = "ip addr show dev enp1s0 | sed -e's/^.*inet6 \\([^ ]*\\)\\/.*$/\\1/;t;d' | head -1"
        #else
            let command = "ifconfig en0 | grep inet6 | grep \"autoconf secured\" | awk -F \" \" '{print $2}' | head -1"
        #endif
        
        guard let shellRet = Shell.run(command) else {
            return nil
        }
        
        let trimmed = shellRet.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 16 {
            return trimmed
        } else {
            return nil
        }

    }
}

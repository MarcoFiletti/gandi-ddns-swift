//
//  IPFetcher.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 15/05/2018.
//

import Foundation

class IPFetcher {
    
    /// Returns a string containing IP if successful, otherwise nil
    static func getIP() -> String? {
        
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
    
}

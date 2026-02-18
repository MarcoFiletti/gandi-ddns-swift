//
//  IPFetcher.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 15/05/2018.
//

import Foundation

@available(macOS 10.15.0, *)
public class IPFetcher {

    /// IPv4 is cached here to prevent sending too many requests
    @MainActor
    static var lastIPv4: String?

    /// IPv6 is cached here to prevent sending too many requests
    @MainActor
    static var lastIPv6: String?

    public enum Error: Swift.Error {
        case fetchFail
    }

    /// Helper function to get the ip depending on record type.
    /// Uses cached values if present to avoid sending too many requests.
    /// - throws: IPFetcher.Error.fetchFail if the address could not be retrieved
    @concurrent
    public static func getIP(forType: RecordType) async throws -> String {
        let maybeIPv4 = await IPFetcher.lastIPv4
        let maybeIPv6 = await IPFetcher.lastIPv6
        
        let maybeAddress: String?
        switch forType {
        case .A:
            if let maybeIPv4 {
                maybeAddress = maybeIPv4
            } else {
                maybeAddress = await getIPv4()
            }
        case .AAAA:
            if let maybeIPv6 {
                maybeAddress = maybeIPv6
            } else {
                maybeAddress = getIPv6()
            }
        }

        guard let foundAddress = maybeAddress else {
            throw IPFetcher.Error.fetchFail
        }

        consolePrint("IP address of current machine for record type \(forType.rawValue) is \(foundAddress)", .verbose)
        return foundAddress
    }
    
    /// Returns a string containing IPv4 if successful, otherwise nil
    @concurrent
    public static func getIPv4() async -> String? {
        
        let ses = URLSession.shared
        guard let ipUrl = URL(string: "https://api.ipify.org") else {
            consolePrint("Failed to create ip url")
            return nil
        }
        
        var ipString: String? = nil
        
        do {
            let (data, _) = try await ses.data(from: ipUrl)
            
            ipString = String(data: data, encoding: .utf8)
            
            await MainActor.run {
                IPFetcher.lastIPv4 = ipString
            }
            
            return ipString

        } catch {
            consolePrint(error.localizedDescription)
            return nil
        }
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
            consolePrint("Shell command to obtain IPv6 failed")
            return nil
        }
        
        let trimmed = shellRet.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 12 {
            Task {
                await MainActor.run {
                    IPFetcher.lastIPv6 = trimmed
                }
            }
            return trimmed
        } else {
            consolePrint("Shell command to obtained IPv6 returned an unexpected result")
            return nil
        }

    }
    
    private static func consolePrint(_ message: String, _ messageLevel: LogLevel = .normal) {
        Task {
            await ConsolePrinter.print(message, messageLevel)
        }
    }
}

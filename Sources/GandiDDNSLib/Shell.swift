//

//  Shell.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 15/05/2018.
//

import Foundation

public class Shell {

    public static func run(_ command: String) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.arguments = ["bash", "-c", command]
        do {
            try task.run()
            task.waitUntilExit()
            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                return String(data: data, encoding: .utf8)
            } else {
                return nil
            }
        } catch {
            Log.print("Failed to launch shell command \"\(command)\"")
            return nil
        }
    }

}

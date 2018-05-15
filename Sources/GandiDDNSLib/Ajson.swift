//
//  ajson.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 15/05/2018.
//

import Foundation

public class Ajson: Codable {
    
    public var a: String
    
    public var b: [Int]
    
    public init() {
        a = "one"
        b = [1 ,2]
    }
    
}

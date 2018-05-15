//
//  ajson.swift
//  GandiDDNS
//
//  Created by Marco Filetti on 15/05/2018.
//

import Foundation

class Ajson: Codable {
    
    var a: String
    
    var b: [Int]
    
    init() {
        a = "one"
        b = [1 ,2]
    }
    
}

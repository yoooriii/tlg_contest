//
//  RawModels.swift
//  TestJson
//
//  Created by Yu Lo on 3/11/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import Foundation

struct RawColumn: Decodable {
    let id: String!
    let values: [Int64]!
    
    init(from decoder: Decoder) throws {
        var elements = try decoder.unkeyedContainer()
        id = try elements.decode(String.self)
        var numbers = [Int64]()
        while !elements.isAtEnd {
            let num = try elements.decode(Int64.self)
            numbers.append(num)
        }
        values = numbers
    }
}

struct RawPlane: Decodable {
    let columns: [RawColumn]!
    let colors: [String: String]!
    let names: [String: String]!
    let types: [String: String]!
}


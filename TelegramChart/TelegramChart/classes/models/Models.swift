//
//  Models.swift
//  TestJson
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import Foundation

protocol Vector {
    var id: String! {get set}
    var values: [Int64]! {get set}
    var minValue: Int64 {get set}
    var maxValue: Int64 {get set}

    init(_ rawColumn:RawColumn)
}

class BasicVector: Vector {
    var id: String!
    var values: [Int64]!
    var minValue: Int64
    var maxValue: Int64

    required init(_ rawColumn:RawColumn) {
        id = rawColumn.id
        values = rawColumn.values
        minValue = rawColumn.minValue!
        maxValue = rawColumn.maxValue!
    }
}

// type 'x'
class VectorTime: BasicVector {
}

// type 'line'
class VectorAmplitude: BasicVector {
    var name: String!
    var colorString: String!

    convenience init(_ rawColumn:RawColumn, colorString: String!, name: String!) {
        self.init(rawColumn)
        self.colorString = colorString
        self.name = name
    }
}

class Plane {
    enum VectorType: String {
        case x = "x"
        case line = "line"
    }

    var vTime: VectorTime!
    var vAmplitudes: [VectorAmplitude]!
    // key: VectorAmplitude.name; value: @localizedName
    var localizedNames: [String:String]?

    init(rawPlane:RawPlane) {

        var amplitudes = [VectorAmplitude]()
        for aColumn in rawPlane.columns {
            guard let id = aColumn.id else { continue }
            guard let rawType = rawPlane.types[id] else { continue }
            guard let type = VectorType(rawValue: rawType) else { continue }

            switch type {
            case .x:
                vTime = VectorTime(aColumn)

            case .line:
                let color = rawPlane.colors[id]
                let name = rawPlane.names[id]
                let amp = VectorAmplitude(aColumn, colorString:color, name:name)
                amplitudes.append(amp)
            }
        }
        vAmplitudes = amplitudes
    }
}

struct GraphicsContainer: Decodable {
    let planes: [Plane]!

    init(from decoder: Decoder) throws {
        var rawItems = try decoder.unkeyedContainer()
        var planes = [Plane]()
        while !rawItems.isAtEnd {
            let rawPlane = try rawItems.decode(RawPlane.self)
            let pl2 = Plane(rawPlane:rawPlane)
            planes.append(pl2)
        }
        self.planes = planes
    }
}

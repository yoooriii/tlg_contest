//
//  Models.swift
//  TestJson
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import Foundation

/// models convenient for ios/macOS internal logic (when raw json models aren't)
/// no UIKit classes available here since the models supposed to work on macOS as well

/// basic interface for both types (x and line)
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

/// class to represent a plane with one x and many y points (axes)
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
            // simple validation logic to prevent using invalid vectors
            guard let id = aColumn.id else { continue }
            guard let rawType = rawPlane.types[id] else { continue }
            guard let type = VectorType(rawValue: rawType) else { continue }

            switch type {
            case .x:
                // FIXIT: what if there is more than one x type item?
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
    var size:Int { get { return planes.count }}

    init(from decoder: Decoder) throws {
        var rawItems = try decoder.unkeyedContainer()
        var planes = [Plane]()
        while !rawItems.isAtEnd {
            let rawPlane = try rawItems.decode(RawPlane.self)
            let plane = Plane(rawPlane:rawPlane)
            planes.append(plane)
        }
        self.planes = planes
    }

    func setLocalizedNames(localizedNames: [String:String]?) {
        for plane in planes {
            plane.localizedNames = localizedNames
        }
    }
}

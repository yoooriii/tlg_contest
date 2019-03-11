//
//  Models.swift
//  TestJson
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import Foundation

protocol Vector {
    associatedtype T
    var id: String! {get set}
    var values: [T]! {get set}
    init(_ rawColumn:RawColumn)
}

// type 'x'
struct VectorTime: Vector {
    typealias T = Int64
    var id: String!
    var values: [T]!

    init(_ rawColumn:RawColumn) {
        values = rawColumn.values as [Int64]
        id = rawColumn.id
    }
}

// type 'line'
struct VectorAmplitude: Vector {
    typealias T = TimeInterval
    var id: String!
    var values: [T]!
    var name: String!
    var colorString: String!

    init(_ rawColumn:RawColumn) {
        values = rawColumn.values.map({ TimeInterval($0) })
        id = rawColumn.id
    }

    init(_ rawColumn:RawColumn, colorString: String!, name: String!) {
        self.init(rawColumn)
        self.colorString = colorString
        self.name = name
    }
}

struct Plane {
    enum VectorType: String {
        case x = "x"
        case line = "line"
    }

    var vTime: VectorTime!
    var vAmplitudes: [VectorAmplitude]!

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

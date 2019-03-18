//
//  LogicCanvas.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/17/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

//import Foundation
//import CoreGraphics
import UIKit

class CanvasSlice {
    var pathModels = [PathModel]()
}

/// this class represents is a square of the size 1000x1000
class LogicCanvas {
    static var SIZE = CGFloat(1000)

    //TODO: decide what to keep Plane or Plane's properties
    var vTime: VectorTime!
    var vAmplitudes: [VectorAmplitude]!
    var lineWidth = CGFloat(2)
    var sliceWidth = CGFloat(100)
    var boundingBox: CGRect?

    init(plane:Plane) {
        vTime = plane.vTime
        vAmplitudes = plane.vAmplitudes
    }

    func slice(at range: VectorRange) -> CanvasSlice? {
        if range.position > Double(LogicCanvas.SIZE) {
            // out of range
            return nil
        }
        guard let timeVals = vTime.values else {
            return nil
        }
        //TODO: replace linear look up algorithm with 2 step approach or smth
        let startTime = vTime.fromNormal(range.position)
        var iStart = 0
        for i in 0..<timeVals.count {
            let time = timeVals[i]
            if time >= startTime {
                iStart = i
                break
            }
        }
        let endTime = vTime.fromNormal(range.endPosition)
        var iEnd = iStart
        for i in iStart..<timeVals.count {
            let time = timeVals[i]
            if time >= endTime {
                iEnd = i
                break
            }
        }
        if iStart >= iEnd {
            iEnd = timeVals.count - 1
            if iStart >= iEnd {
                // nothing found
                return nil
            }
        }

        // start & end indices found, continue
        let slice = CanvasSlice()
        let indices = iStart...iEnd
        for vAmp in vAmplitudes {
            var i = 0
            let path = CGMutablePath()
            for idx in indices {
                var ptX = vTime.normalValue(at:idx) - range.position
                var ptY = vAmp.normalValue(at:idx)
                if let boundingBox = boundingBox {
                    let sy = Double(boundingBox.height / LogicCanvas.SIZE)
                    ptY = ptY * sy
                    let sx = Double(boundingBox.width / LogicCanvas.SIZE) * range.length
                    ptX = ptX * sx
                }
                let pt = CGPoint(x:ptX, y:ptY)
                if 0 == i {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
                i += 1
            }
            let color = vAmp.color ?? UIColor.black
            let pm = PathModel(path:path, color:color, lineWidth:lineWidth)
            slice.pathModels.append(pm)
        }
        return slice
    }

    // it calculates VectorRange using .sliceWidth
    func slice(at index: Int) -> CanvasSlice? {
        return nil
    }

    func createPlane3d() -> Plane3d {
        // convert plane to Plane3d
        let bounds = CGRect(x:0, y:0, width:LogicCanvas.SIZE, height:LogicCanvas.SIZE)
        var arrP2d = [Plane2d]()
        for amp in vAmplitudes {
            var p2d = Plane2d(vTime:vTime, vAmplitude:amp)
            p2d.color = amp.color
            p2d.bounds = bounds
            p2d.path = p2d.pathInRect(bounds)
            arrP2d.append(p2d)
        }
        return Plane3d(planes:arrP2d)
    }
}

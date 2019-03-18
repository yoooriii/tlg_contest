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

/// in essence this is a data provider class
/// this class represents a square of the logic size @SIZE 1000x1000
/// the locic coordinates should be translated to the @viewSize coordinates to show in the view
class LogicCanvas {
    static var SIZE = CGFloat(1000)
    var lineWidth = CGFloat(2)
    var viewSize = CGSize(width:100, height:100)
    var tileRect = CGRect(x:0, y:0, width:100, height:100)

    //TODO: decide what to keep Plane or Plane's properties
    var vTime: VectorTime!
    var vAmplitudes: [VectorAmplitude]!

    init(plane:Plane) {
        vTime = plane.vTime
        vAmplitudes = plane.vAmplitudes
    }

    // based on the @tileRect
    func slice(at index:Int) -> [PathModel]? {
        // copy & move tile rect along the x axe
        var rect = self.tileRect
        rect.origin.x = rect.width * CGFloat(index)
        return slice(rect:rect)
    }

    // rect in view (screen) coordinates
    // result is in view (screen) coordinates
    func slice(rect:CGRect) -> [PathModel]? {
        let scaleX = LogicCanvas.SIZE / viewSize.width
        let scaleY = LogicCanvas.SIZE / viewSize.height
        let viewMinX = rect.minX * scaleX
        let viewMaxX = rect.maxX * scaleX
        let viewMinY = rect.minY * scaleY

        if viewMinX > LogicCanvas.SIZE {
            // out of range
            return nil
        }
        guard let timeVals = vTime.values else {
            return nil
        }
        //TODO: replace linear look up algorithm with 2 step approach or smth
        let startTime = vTime.fromNormal(Double(viewMinX))
        var iStart = 0
        for i in 0..<timeVals.count {
            let time = timeVals[i]
            if time >= startTime {
                iStart = i
                break
            }
        }
        let endTime = vTime.fromNormal(Double(viewMaxX))
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
                print("SLICE: nothing found")
                return nil
            }
        }
        if iStart > 0 {
            // add one more point (start point) to the left
            iStart -= 1
        }
        print("SLICE: [\(iStart):\(iEnd)] from: \(timeVals.count)")

        // start & end indices found, continue
        var slice = [PathModel]()
        let indices = iStart...iEnd
        for vAmp in vAmplitudes {
            let path = CGMutablePath()
            var isFirst = true
            for idx in indices {
                let ptX = (CGFloat(vTime.normalValue(at:idx)) - viewMinX) / scaleX
                let ptY = (CGFloat( vAmp.normalValue(at:idx)) - viewMinY) / scaleY
                let pt = CGPoint(x:ptX, y:ptY)

                if isFirst {    // the 1st point move() and the rest addLine()
                    isFirst = false
                    path.move(to: pt)
                    continue
                }

                path.addLine(to: pt)
            }
            let color = vAmp.color ?? UIColor.black
            let pm = PathModel(path:path, color:color, lineWidth:lineWidth)
            slice.append(pm)
        }
        return slice
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

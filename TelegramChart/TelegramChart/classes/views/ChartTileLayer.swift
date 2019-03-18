//
//  ChartTileLayer.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/15/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class Slice: NSObject {
    var pathModels:[PathModel]!

    init(pathModels:[PathModel]!) {
        super.init()
        self.pathModels = pathModels
    }
}

struct PathModel {
    let path: CGPath!
    let color: UIColor
    let lineWidth: CGFloat

    let min:Int64
    let max:Int64

    init(path: CGPath!, color: UIColor, lineWidth: CGFloat, min:Int64=0, max:Int64=0) {
        self.path = path
        self.color = color
        self.lineWidth = lineWidth
        self.min = min
        self.max = max
    }
}

class ChartTileLayer: CALayer {
    private var contentLayers = [CAShapeLayer]()
    private let maxLayerCount = 5
    private var verticalZoom = CGFloat(1)
    private var verticalOffset = CGFloat(0)

    override init() {
        super.init()
        internalInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }

    private func internalInit() {
        self.isGeometryFlipped = true
        self.masksToBounds = true
        for _ in 0..<maxLayerCount {
            let layer = CAShapeLayer()
            self.addSublayer(layer)
            contentLayers.append(layer)
            layer.backgroundColor = UIColor.clear.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 1.0
            layer.lineJoin = .round
            //TODO: remove debug
            layer.anchorPoint = CGPoint(x:0.5, y:1.0) //???
            layer.borderColor = UIColor.brown.cgColor
            layer.borderWidth = 1.0
        }
    }

    func setPathModels(_ paths:[PathModel]?) {
        if let paths = paths {
            var i = 0
            for layer in contentLayers {
                if i < paths.count {
                    let pathModel = paths[i]
                    layer.path = pathModel.path
                    layer.strokeColor = pathModel.color.cgColor
                    layer.lineWidth = pathModel.lineWidth
                    layer.isHidden = false
                } else {
                    layer.path = nil
                    layer.isHidden = true
                }
                i += 1
            }
        } else {
            for layer in contentLayers {
                layer.path = nil
            }
        }
    }

    // collect & sort out extremums from visible graphs // for debug only
    func getExtremumY() -> MinMax? {
        var min = CGFloat(Int.max)
        var max = CGFloat(Int.min)
        for layer in contentLayers {
            if !layer.isHidden, let path = layer.path {
                let box = path.boundingBoxOfPath
                if min > box.minY { min = box.minY }
                if max < box.maxY { max = box.maxY }
            }
        }
        return min < max ? MinMax(min:min, max:max) : nil
    }

    func clear() {
        verticalZoom = CGFloat(1)
        verticalOffset = CGFloat(0)
        for layer in contentLayers {
            layer.path = nil
            layer.isHidden = true
            layer.setAffineTransform(CGAffineTransform.identity)
        }
    }

    func setVertical(zoom:CGFloat, offset:CGFloat) {
        verticalZoom = zoom
        verticalOffset = offset
//        print("zoom:\(zoom); offs:\(offset);")
        let tt = CGAffineTransform(scaleX: 1.0, y: verticalZoom)
        for layer in contentLayers {
            if !layer.isHidden {
                layer.setAffineTransform(tt)
            }
        }
        setNeedsLayout()
    }

    override func layoutSublayers() {
        var rect = bounds
        rect.origin.y = verticalOffset
        for layer in contentLayers {
            layer.frame = rect
        }
    }
}

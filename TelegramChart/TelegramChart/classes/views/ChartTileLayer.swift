//
//  ChartTileLayer.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/15/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class MyShapeLayer: CAShapeLayer {
    var disableAnimations = false
    // no animations
    override func add(_ anim: CAAnimation, forKey key: String?) {
        if !disableAnimations {
            super.add(anim, forKey: key)
        }
    }
}

class ChartTileLayer: CALayer {
    private var tileWidth = CGFloat(128.0)
    private var contentLayers = [MyShapeLayer]()
    private let maxLayerCount = 5
    private var verticalZoom = CGFloat(1)
    private var verticalOffset = CGFloat(0)
    private var paths:[PathModel]? = nil

    override init() {
        super.init()
        internalInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    func setTileWidth(_ w:CGFloat) {
        tileWidth = w
        setNeedsLayout()
    }

    private func internalInit() {
        self.isGeometryFlipped = true
        self.masksToBounds = true
        for _ in 0..<maxLayerCount {
            let layer = MyShapeLayer()
            self.addSublayer(layer)
            contentLayers.append(layer)
            layer.backgroundColor = UIColor.clear.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 1.0
            layer.lineJoin = .round
            layer.anchorPoint = CGPoint(x:0.0, y:0.0) //???
            //TODO: remove debug
            layer.borderColor = UIColor.yellow.cgColor
            layer.borderWidth = 1.0
        }
    }

    func setPathModels(_ paths:[PathModel]?) {
        self.paths = paths

        let rect = bounds
        let scaleX = rect.width/tileWidth
        var tt0 = CGAffineTransform(scaleX:scaleX, y: 1.0)

        if let paths = paths {
            var i = 0
            for layer in contentLayers {
                if i < paths.count {
                    let pathModel = paths[i]
                    layer.strokeColor = pathModel.color.cgColor
                    layer.lineWidth = pathModel.lineWidth
                    layer.isHidden = false

                    if let path0 = pathModel.path {
                        let scaledPath = path0.copy(using: &tt0)
                        layer.path = scaledPath
                    } else {
                        layer.path = nil
                    }

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

        let tt = CGAffineTransform(scaleX: 1.0, y: verticalZoom)
        for layer in contentLayers {
            if !layer.isHidden { // maybe scale hidden layers as well?
                layer.setAffineTransform(tt)
            }
        }
    }

    override func layoutSublayers() {
        let rect = bounds
        let scaleX = rect.width/tileWidth
        var tt0 = CGAffineTransform(scaleX:scaleX, y: 1.0)
        if let paths = paths {
            let count = min(contentLayers.count, paths.count)
            for i in 0..<count {
                let layer = contentLayers[i]
                let pathModel = paths[i]
                if let path0 = pathModel.path {
                    let scaledPath = path0.copy(using: &tt0)
                    layer.path = scaledPath
                } else {
                    layer.path = nil
                }
            }
        }

        //TODO: combine 2 for-each loops in 1
        for layer in contentLayers {
            // notice: I use bounds instead of frame here (see: anchorPoint)
            let wasDisabled = layer.disableAnimations
            layer.disableAnimations = true
            layer.bounds = rect
            layer.disableAnimations = wasDisabled
        }
    }
}

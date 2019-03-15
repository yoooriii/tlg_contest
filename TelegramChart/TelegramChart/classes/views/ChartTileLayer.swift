//
//  ChartTileLayer.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/15/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

struct PathModel {
    let path: CGPath?
    let color: UIColor
    let lineWidth: CGFloat
}

class ChartTileLayer: CALayer {
    var contentLayers = [CAShapeLayer]()
    let maxLayerCount = 5

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
        for _ in 0..<maxLayerCount {
            let layer = CAShapeLayer()
            self.addSublayer(layer)
            contentLayers.append(layer)
            layer.backgroundColor = UIColor.clear.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 1.0
            layer.lineJoin = .round
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

    func clear() {
        for layer in contentLayers {
            layer.path = nil
            layer.isHidden = true
        }
    }

    override func layoutSublayers() {
        for layer in contentLayers {
            layer.frame = bounds
        }
    }
}

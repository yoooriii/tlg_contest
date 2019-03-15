//
//  ChartShapeLayer.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/14/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class ChartShapeLayer: CAShapeLayer {
    func setPlane2d(_ plane2d:Plane2d?) {
        let shapeLayer = self
        if let plane2d = plane2d {
            if let path = plane2d.path, let bounds = plane2d.bounds {
                let box = path.boundingBox
                print("box: \(box)")

                let bounds2 = self.bounds
                let sx = bounds2.width / bounds.width
                let sy = bounds2.height / bounds.height
                var transform = CGAffineTransform(scaleX:sx,y:sy)
                let path2 = path.copy(using: &transform)
                shapeLayer.path = path2
                shapeLayer.strokeColor = (plane2d.color ?? UIColor.black).cgColor
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.lineWidth = 1.0
            }
        } else {
            shapeLayer.path = nil
        }
    }
}

class ChartMultiShapeLayer: CALayer {
    private var graphLayers = [ChartShapeLayer]()
    private let maxLayerCount = 5 // 5 layers must be enough

    override init() {
        super.init()
        internalInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }

    private func internalInit() {
        isGeometryFlipped = true
        let scale = UIScreen.main.scale
        for _ in 0..<maxLayerCount {
            let sbLayer = ChartShapeLayer()
            graphLayers.append(sbLayer)
            addSublayer(sbLayer)

            sbLayer.backgroundColor = UIColor.clear.cgColor
            sbLayer.isGeometryFlipped = false
            sbLayer.contentsScale = scale
        }
        setNeedsLayout()
    }

    override func layoutSublayers() {
        for chartLayer in graphLayers {
            chartLayer.frame = bounds
        }
    }

    func setPlane3d(_ p3d:Plane3d) {
        let modelCount = p3d.planes.count
        for i in 0..<graphLayers.count {
            let layer = graphLayers[i]
            let isHidden = modelCount <= i
            layer.isHidden = isHidden
            if !isHidden {
                let p2d = p3d.planes[i]
                layer.setPlane2d(p2d)
            }
        }
    }

    func clear() {
        for layer in graphLayers {
            layer.isHidden = true
            layer.setPlane2d(nil)
        }
    }
}

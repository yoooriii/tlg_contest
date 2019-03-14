//
//  ChartView.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/13/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

class ChartView: UIView {
    private var plane:Plane2d?
    private var graphLayers = [ChartShapeLayer]()
    private let maxLayerCount = 5 // 5 layers must be enough

    override func awakeFromNib() {
        super.awakeFromNib()

        let scale = UIScreen.main.scale
        for _ in 0..<maxLayerCount {
            let sbLayer = ChartShapeLayer()
            graphLayers.append(sbLayer)
            self.layer.addSublayer(sbLayer)

            sbLayer.backgroundColor = UIColor.clear.cgColor
            sbLayer.isGeometryFlipped = true
            sbLayer.contentsScale = scale
        }
        self.layer.setNeedsLayout()
    }

    override func layoutSublayers(of layer: CALayer) {
        if layer == self.layer {
            for chartLayer in graphLayers {
                chartLayer.frame = layer.bounds
            }
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

}

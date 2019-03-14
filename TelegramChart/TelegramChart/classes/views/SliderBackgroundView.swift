//
//  SliderBackgroundView.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

protocol ChartInterface {
    func setPlane(_ plane:Plane)
}

class BGLayer: CALayer {
    private var graphLayers = [ChartShapeLayer]()

    func awake() {
        let scale = UIScreen.main.scale
        for _ in 0..<5 {    // 5 layers must be enough
            let sbLayer = ChartShapeLayer()
            graphLayers.append(sbLayer)
            self.addSublayer(sbLayer)

            sbLayer.backgroundColor = UIColor.clear.cgColor
            sbLayer.isGeometryFlipped = true
            sbLayer.contentsScale = scale
        }
        setNeedsLayout()
    }

    override func layoutSublayers() {
        for gl in graphLayers {
            gl.frame = self.bounds
        }
    }

    func setPlane3d(_ p3d:Plane3d) {

        let ampCount = p3d.planes.count
        let layCount = graphLayers.count
        if ampCount > layCount {
            print("some charts won't show [\(ampCount) > \(layCount)]")
        }

        for i in 0..<layCount {
            let layer = graphLayers[i]
            let isHidden = i >= ampCount
            // hide unused layers
            layer.isHidden = isHidden
            if !isHidden {
                let p2d = p3d.planes[i]
                layer.setPlane2d(p2d)
            }
        }
    }
}

class SliderBackgroundView: UIView {

    override class var layerClass: AnyClass { return BGLayer.self }

    override func awakeFromNib() {
        bgLayer?.awake()
    }

    var shapeLayer: CAShapeLayer? {
        return self.layer as? CAShapeLayer
    }

    var bgLayer: BGLayer? {
        return self.layer as? BGLayer
    }

    func setPlane3d(_ p3d:Plane3d) {
        self.bgLayer?.setPlane3d(p3d)
    }
}

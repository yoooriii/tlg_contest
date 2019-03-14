//
//  ChartShapeLayer.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/14/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class ChartShapeLayer: CAShapeLayer {
    func setPlane2d(_ plane2d:Plane2d) {
        let shapeLayer = self
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
    }
}

//
//  ShapeView.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/16/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class ShapeView: UIView {
    override class var layerClass: AnyClass { get { return CAShapeLayer.self } }

    var shapeLayer: CAShapeLayer? { get { return self.layer as? CAShapeLayer }}
}

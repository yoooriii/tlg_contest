//
//  SliderBackgroundView.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

class SliderBackgroundView: UIView {
    override class var layerClass: AnyClass { return CAShapeLayer.self }

    var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
}

//
//  SliderView.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

class ScaleSliderView: UIView {
    @IBOutlet var sliderCenter: UIView!
    @IBOutlet var sliderLeft: UIView!
    @IBOutlet var sliderRight: UIView!
    @IBOutlet var backgroundView: SliderBackgroundView?
    @IBOutlet var constraintLeft: NSLayoutConstraint!
    @IBOutlet var constraintRight: NSLayoutConstraint!

    var fixSliderWidth:CGFloat = -1
    var dxl:CGFloat = -1
    var dxr:CGFloat = -1
    let minMargin:CGFloat = 10
    let minWidth:CGFloat = 50

    enum Move {
        case left
        case center
        case right
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        wakeContent()
    }

    private func wakeContent() {
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1


        if let bgView = backgroundView, let shapeLayer = bgView.shapeLayer {

            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.fillColor = UIColor.yellow.cgColor

            let path = CGMutablePath()
            stride(from: 0.0, to: 1000.0, by: 15.0).forEach {
                x in
                var transform  = CGAffineTransform(translationX: CGFloat(x), y: -5)

                let petal = CGPath(ellipseIn: CGRect(x: -20, y: 0, width: 40, height: 100),
                                   transform: &transform)

                path.addPath(petal)
            }

            shapeLayer.path = path
        }

    }

    @IBAction func onCenterSlide(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let x = recognizer.location(in: self).x
            fixSliderWidth = self.sliderCenter.frame.width
            dxl = x - constraintLeft.constant
            dxr = x - constraintRight.constant

        case .changed:
            let x = recognizer.location(in: self).x
            let xl = x - self.sliderLeft.frame.width/2.0 - dxl
            let xr = x - self.sliderRight.frame.width/2.0 - dxr
            self.constraintLeft.constant = xl
            self.constraintRight.constant = xr

        case .possible:
            break

        case .cancelled, .ended:
            fixSliderWidth = -1
            dxl = -1
            dxr = -1
            validatePosition(.center)

        case .failed:
            break
        }
    }

    @IBAction func onLeftSlide(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            break

        case .changed:
            self.constraintLeft.constant = recognizer.location(in: self).x - self.sliderLeft.frame.width/2.0
        case .possible:
            break

        case .cancelled, .ended:
            validatePosition(.left)

        case .failed:
            break
        }
    }

    @IBAction func onRightSlide(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            break
        case .changed:
            self.constraintRight.constant = recognizer.location(in: self).x - self.sliderRight.frame.width/2.0
        case .possible:
            break
        case .cancelled, .ended:
            validatePosition(.right)

        case .failed:
            break
        }
    }

    private func validatePosition(_ move:Move) {
        var fixWidth = constraintRight.constant - constraintLeft.constant
        var xl = constraintLeft.constant
        var xr = constraintRight.constant
        let dw = fixWidth - minWidth
        if dw < 0 {
            fixWidth = minWidth
            switch move {
            case .left:
                xl = xr - fixWidth
            case .right:
                xr = xl + fixWidth
            case .center:
                break
            }
        }

        if constraintLeft.constant < minMargin {
            xl = minMargin
            xr = minMargin + fixWidth
        }

        let w = self.bounds.width
        let xr2 = constraintRight.constant + sliderRight.frame.width + minMargin
        if xr2 > w {
            let xr0 = w - minMargin - sliderRight.frame.width
            xr = xr0
            xl = xr0 - fixWidth
        }

        constraintLeft.constant = xl
        constraintRight.constant = xr
    }

    // DEBUG
    @IBAction func debugSlide(_ slider: UISlider) {
        let v = slider.value
        print("slider \(v)")
    }

}

extension ScaleSliderView: ChartInterface {
    func setPlane(_ plane:Plane) {
        self.backgroundView?.setPlane(plane)
    }
}

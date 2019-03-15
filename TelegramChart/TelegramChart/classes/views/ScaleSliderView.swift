//
//  SliderView.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

@objc protocol ScaleSliderViewDelegate {
    func sliderChanging(_ slider:ScaleSliderView)
    func sliderDidChange(_ slider:ScaleSliderView, position:CGFloat)
    func sliderDidChange(_ slider:ScaleSliderView, zoom:CGFloat)
}

class ScaleSliderView: UIView {
    @IBOutlet var sliderCenter: UIView!
    @IBOutlet var sliderLeft: UIView!
    @IBOutlet var sliderRight: UIView!
    @IBOutlet var backgroundView: SliderBackgroundView?
    @IBOutlet var constraintLeft: NSLayoutConstraint!
    @IBOutlet var constraintRight: NSLayoutConstraint!
    @IBOutlet var delegate:ScaleSliderViewDelegate?

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
    }

    @IBAction func onCenterSlide(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let x = recognizer.location(in: self).x
            dxl = x - constraintLeft.constant
            dxr = x - constraintRight.constant

        case .changed:
            let x = recognizer.location(in: self).x
            let xl = x - self.sliderLeft.frame.width/2.0 - dxl
            let xr = x - self.sliderRight.frame.width/2.0 - dxr
            self.constraintLeft.constant = xl
            self.constraintRight.constant = xr
            delegate?.sliderChanging(self)

        case .possible:
            break

        case .cancelled:
            dxl = -1
            dxr = -1
            validatePosition(.center)
//            delegate?.sliderDidChange(self, position: getPosition())

        case .ended:
            dxl = -1
            dxr = -1
            validatePosition(.center)
            delegate?.sliderDidChange(self, position: getPosition())

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
            delegate?.sliderChanging(self)

        case .possible:
            break

        case .ended:
            validatePosition(.left)
            delegate?.sliderDidChange(self, zoom: getZoom())

        case .cancelled:
            validatePosition(.left)
//            delegate?.sliderDidChange(self, zoom: getZoom())

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
            delegate?.sliderChanging(self)

        case .possible:
            break

        case .ended:
            validatePosition(.right)
            delegate?.sliderDidChange(self, zoom: getZoom())

        case .cancelled:
            validatePosition(.right)
//            delegate?.sliderDidChange(self, zoom: getZoom())

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

    /// zoom and position normalized [0...1]
    func getPosition() -> CGFloat {
        return ((constraintLeft.constant + constraintRight.constant)/2.0 - frame.minX) / bounds.width

    }
    func getZoom() -> CGFloat {
        return (constraintRight.constant - constraintLeft.constant) / bounds.width
    }

    // DEBUG
    @IBAction func debugSlide(_ slider: UISlider) {
        let v = slider.value
        print("slider \(v)")
    }

//////////
    func setPlane3d(_ p3d:Plane3d) {
        backgroundView?.setPlane3d(p3d)
    }

}

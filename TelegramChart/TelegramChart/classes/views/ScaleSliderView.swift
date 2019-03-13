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
    @IBOutlet var backgroundView: SliderBackgroundView!
    @IBOutlet var constraintLeft: NSLayoutConstraint!
    @IBOutlet var constraintRight: NSLayoutConstraint!

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


        let shapeLayer = backgroundView.shapeLayer
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.yellow.cgColor
        let path = CGMutablePath()

        stride(from: 0.0, to: 1000.0, by: 15.0).forEach {
            x in
            var transform  = CGAffineTransform(translationX: CGFloat(x), y: 30)

            let petal = CGPath(ellipseIn: CGRect(x: -20, y: 0, width: 40, height: 100),
                               transform: &transform)

            path.addPath(petal)
        }

        shapeLayer.path = path

    }

    @IBAction func onCenterSlide(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            print("center.began: \(recognizer.location(in: self).x)")
        case.cancelled:
            break
        case .changed:
            let centerWidth2 = self.sliderCenter.frame.width/2.0
            let xl = recognizer.location(in: self).x - self.sliderLeft.frame.width/2.0 - centerWidth2
            let xr = self.bounds.width - recognizer.location(in: self).x - self.sliderRight.frame.width/2.0 + centerWidth2
            print("center.changed: \(recognizer.location(in: self).x); []=[\(xl) : \(xr)]")
            self.constraintLeft.constant = xl
//            self.constraintRight.constant = xr
        case .possible:
            break
        case .ended:
            print("center.ended: \(recognizer.location(in: self).x)")

        case .failed:
            break
        }
    }

    @IBAction func onLeftSlide(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            print("left.began: \(recognizer.location(in: self).x)")
        case.cancelled:
            break
        case .changed:
            print("left.changed: \(recognizer.location(in: self).x)")
            self.constraintLeft.constant = recognizer.location(in: self).x - self.sliderLeft.frame.width/2.0
        case .possible:
            break
        case .ended:
            print("left.ended: \(recognizer.location(in: self).x)")

        case .failed:
            break
        }
    }

    @IBAction func onRightSlide(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            print("right.began: \(recognizer.location(in: self).x)")
        case.cancelled:
            break
        case .changed:
            print("right.changed: \(recognizer.location(in: self).x)")
            self.constraintRight.constant = self.bounds.width - recognizer.location(in: self).x - self.sliderRight.frame.width/2.0
        case .possible:
            break
        case .ended:
            print("right.ended: \(recognizer.location(in: self).x)")

        case .failed:
            break
        }
    }
}

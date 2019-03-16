//
//  ZoomVC.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/16/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class ZoomVC: UIViewController {
    @IBOutlet var shapeView: ShapeView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!

    var tx:CGFloat = 1.0
    var ty:CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        if let shapeLayer = shapeView.shapeLayer {
            let path = TestModels.path256Circle()
            shapeLayer.path = path
            shapeLayer.lineWidth = 5
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.backgroundColor = UIColor.black.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
        } else {
            print("no shape layer")
        }

    }

    @IBAction func sliderChangeActionX(_ sender: UISlider) {
        print("x: \(sender.value * 100.0)")

        if let shapeLayer = shapeView.shapeLayer {
            tx = CGFloat(sender.value * 2.5 + 0.5)
            let tt = CGAffineTransform(scaleX: tx, y: ty)
            shapeLayer.setAffineTransform(tt)
        }
    }

    @IBAction func sliderChangeActionY(_ sender: UISlider) {
        print("Y: \(sender.value * 100.0)")

        if let shapeLayer = shapeView.shapeLayer {
            ty = CGFloat(sender.value * 2.5 + 0.5)
            let tt = CGAffineTransform(scaleX: tx, y: ty)
            shapeLayer.setAffineTransform(tt)
        }
    }

    @IBAction func goBack(_ sender: UIButton) {
        print("back")
        dismiss(animated: true) {
            print("dismissed")
        }
    }


}

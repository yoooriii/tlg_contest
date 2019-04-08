//
//  TestSceneVC.swift
//  TestSceneApp
//
//  Created by Yu Lo on 4/8/19.
//  Copyright © 2019 Leonid. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class TestSceneVC: UIViewController {
    @IBOutlet var skView:SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SKScene(size: skView.bounds.size)
        // Set the scene coordinates (0, 0) to the center of the screen.
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        skView.presentScene(scene)
        scene.backgroundColor = .gray

        let shape = createShape()
        scene.addChild(shape)

        let shape2 = createShape2()
        scene.addChild(shape2)
    }

    func createShape() -> SKShapeNode {
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero,
                    radius: 15,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        let ball = SKShapeNode(path: path)
        ball.lineWidth = 1
        ball.fillColor = .blue
        ball.strokeColor = .white
        ball.glowWidth = 5

        return ball
    }

    func createShape2() -> SKShapeNode {
        let path = CGMutablePath()
        let sideW = CGFloat(300)
        let sideH = CGFloat(100)
        let bounds = CGRect(origin: CGPoint(x: -sideW/2.0, y: -sideH/2.0), size: CGSize(width: sideW, height: sideH))
        let count = 30
        var x = bounds.minX
        let dx = bounds.width / CGFloat(count)
        let amplitude = bounds.height
        let k = CGFloat(0.3)
        for i in 0...count {
            let y = sin(x * k) * amplitude
            let pt = CGPoint(x:x, y:y)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }

            x += dx
        }

        x = bounds.minX
        for _ in 0...count {
            let y = sin(x * k) * amplitude
            let pt = CGPoint(x:x, y:y)

            let r = CGRect(origin: pt, size: CGSize.zero).insetBy(dx: -2, dy: -2)
            path.addEllipse(in: r)

            x += dx
        }
        let sinShape = SKShapeNode(path: path)
        sinShape.lineWidth = 1.5
        sinShape.fillColor = .clear
        sinShape.strokeColor = .red
        sinShape.glowWidth = 0

        return sinShape
    }


    @IBAction func changeValueAction(_ sender: UISlider) {

    }
}

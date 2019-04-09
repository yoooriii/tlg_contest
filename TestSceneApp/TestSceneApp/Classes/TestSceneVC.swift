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
    private var contentsCreated = false
    var sinShape: SKShapeNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        createContents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func createContents() {
        // do it once
        if contentsCreated { return }
        contentsCreated = true

        let scene = SKScene(size: skView.bounds.size)
        /* Modify the SKScene's actual size to exactly match the SKView. */
        scene.scaleMode = .resizeFill
        scene.delegate = self
        // Set the scene coordinates (0, 0) to the center of the screen.
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        skView.presentScene(scene)
        scene.backgroundColor = .gray
        
        let shape = createTargetShape()
        scene.addChild(shape)
        
        sinShape = createSinShape()
        scene.addChild(sinShape)
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
    
    func createTargetShape() -> SKShapeNode {
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero,
                    radius: 50,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        let node = SKShapeNode(path: path)
        node.lineWidth = 1
        node.fillColor = .clear
        node.isAntialiased = false
        node.strokeColor = .red // it doesn't work id strokeShader in use
        
        let dashedShader = SKShader(source: "void main() {" +
            "int stripe = int(u_path_length) / 50;" +
            "int h = int(v_path_distance) / stripe % 2;" +
            "if (0==h) { gl_FragColor =  float4(0, 0, 1, 1); } " +
            "else { gl_FragColor = vec4(SKDefaultShading().rgb, SKDefaultShading().a); }" +
            "}")
        node.strokeShader = dashedShader

        return node
    }
    

    func createSinShape() -> SKShapeNode {
        let size = CGSize(width: 300, height: 20)
        let bounds = CGRect(origin: CGPoint(x: -size.width/2.0, y: -size.height/2.0), size: size)
        let path = Common.createSinPath(bounds: bounds, count: 100)
        
        let sinShape = SKShapeNode(path: path)
        sinShape.lineWidth = 1.5
        sinShape.fillColor = .clear
        sinShape.strokeColor = .red
        sinShape.glowWidth = 0

        return sinShape
    }

    private func denormalize(min:CGFloat, max:CGFloat, val:CGFloat) -> CGFloat {
        return min + (max - min) * val
    }

    @IBAction func changeValueAction(_ sender: UISlider) {
        let val = denormalize(min: 0.3, max: 10, val: CGFloat(sender.value))
        sinShape.yScale = val
    }
}

extension TestSceneVC: SKSceneDelegate {
    //    func update(_ currentTime: TimeInterval, for scene: SKScene)
    //
    //    func didEvaluateActions(for scene: SKScene)
    //
    //    func didSimulatePhysics(for scene: SKScene)
    //
    //
    //    func didApplyConstraints(for scene: SKScene)
    //
    //    func didFinishUpdate(for scene: SKScene)
}

//
//  TestShape3dVC.swift
//  TestSceneApp
//
//  Created by Leonid Lokhmatov on 4/9/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit
import QuartzCore
import SceneKit

class TestShape3dVC: UIViewController {
    @IBOutlet var scnView:SCNView!
    private var contentsCreated = false
    private var lineWidth = Float(5.0)
    private var testNode:SCNNode?
    private var defaultScale = CGFloat(10)
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createConrents()
    }
    
    private func createConrents() {
        if contentsCreated { return }
        contentsCreated = true
        
        let scene = SCNScene()
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        scnView.delegate = self
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.lightGray

        let shapeNode = createShapeNode()
        scene.rootNode.addChildNode(shapeNode)
        testNode = shapeNode

        let shapeNode2 = createShapeNode()
        shapeNode2.position = SCNVector3(-20, 0, 0)
        scene.rootNode.addChildNode(shapeNode2)

        let shapeNode3 = createShapeNode()
        shapeNode3.position = SCNVector3(20, 0, 0)
        scene.rootNode.addChildNode(shapeNode3)


        if true {
            // create and add a camera to the scene
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            scene.rootNode.addChildNode(cameraNode)

            // place the camera
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 100)
        }
    }
    
    private func createShapeNode() -> SCNNode {
        let shapeGeometry = createShape()
        let shapeNode = SCNNode(geometry: shapeGeometry)
        //        shapeNode.position = SCNVector3(0, 1.5, 0)
        
        shapeNode.position = SCNVector3(0,0,0)
        shapeNode.scale = SCNVector3(defaultScale, defaultScale, 1)
        return shapeNode
    }
    
    private func createShape() -> SCNShape {
        let rect = CGRect(x:0, y:0, width:0.1, height:0.1)
//        let path = CGPath(ellipseIn: rect, transform: nil)//Common.createSinPath(bounds: rect, count: 100)
        let a = CGFloat(1)
        let bz = UIBezierPath()
        bz.move(to: CGPoint(x:-a, y:-a))
        bz.addLine(to: CGPoint(x:0, y:a))
        bz.addLine(to: CGPoint(x:a, y:-a))
        bz.close()
        bz.lineWidth = 0.5
        let shape = SCNShape(path: bz, extrusionDepth: 0.01)
        shape.firstMaterial?.diffuse.contents = UIColor.blue

        return shape
    }
    
    private func denormalize(min:CGFloat, max:CGFloat, val:CGFloat) -> CGFloat {
        return min + (max - min) * val
    }
    
    @IBAction func changeValueAction(_ sender: UISlider) {
        let val = denormalize(min: 0.1, max: 1.5, val: CGFloat(sender.value))
        print("val \(val)")
//        sinShape.yScale = val
        if let testNode = testNode {
            let v = Float(val * defaultScale)
            testNode.scale = SCNVector3(v,v,1)
        }
    }
}

extension TestShape3dVC: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //        glEnable(GL_COLOR_MATERIAL)
        //        glColor4f(1.0, 0.0, 0.0, 1.0)
        glLineWidth(lineWidth)
    }
}

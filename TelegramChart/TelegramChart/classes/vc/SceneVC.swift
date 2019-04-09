//
//  SceneVC.swift
//  TelegramChart
//
//  Created by Yu Lo on 4/9/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit
import SceneKit

class SceneVC: UIViewController {
    @IBOutlet var scnView: SCNView!
    @IBOutlet var infoLabel: UILabel!

    private var lineWidth = CGFloat(5.0)
    private var testNode:SCNNode?
    private var defaultScale = CGFloat(100)
    private var contentsCreated = false
    private var scene: SCNScene!


    private var planeIndex = -1
    var selectedIndex:Int { set { planeIndex = newValue } get { return planeIndex } }
    var graphicsContainer:GraphicsContainer? {
        didSet {
            if let graphicsContainer = graphicsContainer {
                planeIndex = (graphicsContainer.planes.count > 0) ? 0 : -1
            } else { planeIndex = -1 } }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createConrents()
    }


    private func denormalize(min:CGFloat, max:CGFloat, val:CGFloat) -> CGFloat {
        return min + (max - min) * val
    }

    @IBAction func changeValueAction(_ sender: UISlider) {
        let val = denormalize(min: 0.1, max: 6, val: CGFloat(sender.value))
        print("val \(val)")
        //        sinShape.yScale = val
        if let testNode = testNode {
            let v = Float(val * defaultScale)
            testNode.scale = SCNVector3(v,Float(defaultScale),1)
        }
    }

    @IBAction func showNextAction(_ sender: UIButton) {
        showNextPlane()
    }

    private func showNextPlane() {
        showPlane(index: planeIndex)
        planeIndex += 1
        if let container = graphicsContainer {
            let plCount = container.size
            if planeIndex >= plCount {
                planeIndex = 0
            }
        } else {
            print("no container")
            planeIndex = -1
        }
    }

    private func showPlane(index:Int) {
        guard let container = graphicsContainer  else {
            print("no graphicsContainer")
            infoLabel.text = "no graphicsContainer"
            return
        }

        let plCount = container.size
        if index < 0 || index >= plCount {
            print("wrong index \(index)")
            infoLabel.text = "wrong index \(index)"
            return
        }

        var infoTxt = "#[\(index):\(container.planes.count)]: "
        let plane = container.planes[index]

        if true {
            let time = plane.vTime.basicCopy(normal: 1)
            let amp = plane.vAmplitudes[0].basicCopy(normal: 1)
            if time.count != amp.count {
                print("wrong (amp,time) count")
                return
            }
            let count = time.count
            let path = CGMutablePath()
            path.move(to: CGPoint(x:-0.5, y:-0.55))
            for i in 0..<count {
                let x = (Double(time.values[i]) - Double(time.minValue)) / time.scale - 0.5
                let y = (Double(amp.values[i]) - Double(amp.minValue)) / amp.scale - 0.5
                path.addLine(to: CGPoint(x:x, y:y))
            }
            path.addLine(to: CGPoint(x:0.5, y:-0.55))
            path.closeSubpath()

            let bz = UIBezierPath(cgPath: path)
            let shapeGeometry = SCNShape(path: bz, extrusionDepth: 0.1)
            shapeGeometry.firstMaterial?.diffuse.contents = UIColor.blue
            let shapeNode = SCNNode(geometry: shapeGeometry)
            shapeNode.position = SCNVector3(0,0,0)
            shapeNode.scale = SCNVector3(defaultScale, defaultScale, 1)

            if let testNode = testNode {
                testNode.removeFromParentNode()
            }
            testNode = shapeNode
            scene.rootNode.addChildNode(shapeNode)
        }
    }

    private func createConrents() {
        if contentsCreated { return }
        contentsCreated = true

        scene = SCNScene()

        // set the scene to the view
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        scnView.delegate = self

        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.lightGray

        if true {
            // create and add a camera to the scene
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            scene.rootNode.addChildNode(cameraNode)

            // place the camera
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 100)
        }
    }
}


extension SceneVC: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //        glEnable(GL_COLOR_MATERIAL)
        //        glColor4f(1.0, 0.0, 0.0, 1.0)
        glLineWidth(Float(lineWidth))
    }
}

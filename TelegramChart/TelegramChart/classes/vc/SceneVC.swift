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
    @IBOutlet var slider1:UISlider!
    @IBOutlet var slider2:UISlider!

    private var lineWidth = CGFloat(5.0)
    private var testNode = [SCNNode]()
    private var defaultScale = Float(100)
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
        showNextPlane()
    }


    private func denormalize(min:Float, max:Float, val:Float) -> Float {
        return min + (max - min) * val
    }

    @IBAction func actChangeVal1(_ sender: UISlider) {
        let val2 = denormalize(min: 0.1, max: 6, val:slider2.value) * defaultScale
        let val1 = denormalize(min: 0.1, max: 6, val:slider1.value) * defaultScale
        for node in testNode {
            node.scale = SCNVector3(val1, val2, 1)
        }
    }

    @IBAction func actChangeVal2(_ sender: UISlider) {
        let val2 = denormalize(min: 0.1, max: 6, val:slider2.value) * defaultScale
        let val1 = denormalize(min: 0.1, max: 6, val:slider1.value) * defaultScale
        for node in testNode {
            node.scale = SCNVector3(val1, val2, 1)
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

        let plane = container.planes[index]
        let extrusionDepth = CGFloat(0.0)

        for node in testNode {
            node.removeFromParentNode()
        }
        testNode.removeAll()

        var mass = [(Int,Float)]()
        let ampCount = plane.vAmplitudes.count
        for j in 0..<ampCount {
            let color = plane.vAmplitudes[j].color
            let count = plane.vTime.count
            if count != plane.vAmplitudes[j].count {
                print("wrong (amp,time) count")
                return
            }
            let path = UIBezierPath()
            path.move(to: CGPoint(x:-0.5, y:-0.501))
            for i in 0..<count {
                let x = plane.vTime.normalValue1(at: i) - 0.5
                let y = plane.vAmplitudes[j].normalValue1(at: i) - 0.5
                path.addLine(to: CGPoint(x:x, y:y))
            }
            path.addLine(to: CGPoint(x:0.5, y:-0.501))
            path.close()

            let shapeGeometry = SCNShape(path: path, extrusionDepth: extrusionDepth)
            shapeGeometry.firstMaterial?.diffuse.contents = color ?? UIColor.black
            let shapeNode = SCNNode(geometry: shapeGeometry)
            shapeNode.position = SCNVector3(0, 0, Float(j)*0.01) // not sure about Z
            shapeNode.renderingOrder = j
            shapeNode.scale = SCNVector3(defaultScale, defaultScale, 1)
            shapeNode.name = "amp #\(j)"

            testNode.append(shapeNode)
            scene.rootNode.addChildNode(shapeNode)
            let avg = plane.vAmplitudes[j].avg()
            mass.append((j, avg))
        }

        mass.sort { (lv, rv) -> Bool in
            return lv.1 < rv.1
        }
        for i in 0..<testNode.count {
            let m = mass[i]
            let n = testNode[m.0]
            n.position = SCNVector3(0, 0, Float(i)*0.01) // not sure about Z
            n.renderingOrder = i
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

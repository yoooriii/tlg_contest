//
//  GameViewController.swift
//  TestSceneApp
//
//  Created by Leonid Lokhmatov on 4/8/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        scnView.delegate = self

        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.magenta
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        //==================
        let icosahedron = generateIcosahedron()
        let icosahedronNode = SCNNode(geometry: icosahedron)
        icosahedronNode.position = SCNVector3(0, 1.5, 0)
        scene.rootNode.addChildNode(icosahedronNode)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.green
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    func generateIcosahedron() -> SCNGeometry {
        
        let t = (1.0 + sqrt(5.0)) / 2.0;
        
        let vertices: [SCNVector3] = [
            SCNVector3(-1,  t, 0), SCNVector3( 1,  t, 0), SCNVector3(-1, -t, 0), SCNVector3( 1, -t, 0),
            SCNVector3(0, -1,  t), SCNVector3(0,  1,  t), SCNVector3(0, -1, -t), SCNVector3(0,  1, -t),
            SCNVector3( t,  0, -1), SCNVector3( t,  0,  1), SCNVector3(-t,  0, -1), SCNVector3(-t,  0,  1) ]
        
        
        let data = NSData(bytes: vertices, length: MemoryLayout<SCNVector3>.size * vertices.count) as Data
        
        let vertexSource = SCNGeometrySource(data: data,
                                             semantic: .vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<SCNVector3>.stride)
        
        let indices: [Int32] = [
            0, 5, 1, 0, 1, 5, 1, 7, 1, 8, 1, 9, 2, 3, 2, 4, 2, 6, 2, 10, 2, 11, 3, 6, 3, 8, 3, 9, 4, 3, 4, 5,
            4, 9, 5, 9, 6, 7, 6, 8, 6, 10, 9, 8, 8, 7, 7, 0, 10, 0, 10, 7, 10, 11, 11, 0, 11, 4, 11, 5 ]
        
        let indexData = NSData(bytes: indices, length: MemoryLayout<Int32>.size * indices.count) as Data
        
        let element = SCNGeometryElement(data: indexData,
                                         primitiveType: .line,
                                         primitiveCount: indices.count/2,
                                         bytesPerIndex: MemoryLayout<Int32>.size)
        ////// Add colors
        var vertexColors = [SCNVector3]()
        
        for _ in 0..<vertices.count {
            
            let red = Float(arc4random() % 255) / 255.0
            let green = Float(arc4random() % 255) / 255.0
            let blue = Float(arc4random() % 255) / 255.0
            
            vertexColors.append(SCNVector3(red, green, blue))
        }
        
        
        let dataColor = NSData(bytes: vertexColors, length: MemoryLayout<SCNVector3>.size * vertices.count) as Data
        
        let colors = SCNGeometrySource(data: dataColor,
                                       semantic: .color,
                                       vectorCount: vertexColors.count,
                                       usesFloatComponents: true,
                                       componentsPerVector: 3,
                                       bytesPerComponent: MemoryLayout<Float>.size,
                                       dataOffset: 0,
                                       dataStride: MemoryLayout<SCNVector3>.stride)
        
        return SCNGeometry(sources: [vertexSource, colors], elements: [element])
    }
    
}

extension GameViewController:SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        glLineWidth(10)
    }
}

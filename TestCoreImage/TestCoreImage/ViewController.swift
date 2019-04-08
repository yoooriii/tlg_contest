//
//  ViewController.swift
//  TestCoreImage
//
//  Created by Leonid Lokhmatov on 4/8/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit
import CoreImage
import simd

class ViewController: UIViewController {
    let img1 = UIImage(named: "shrek")
    let img2 = UIImage(named: "wallace")
    var displayLink:CADisplayLink?
    
    var time:TimeInterval = 0
    var dt:TimeInterval = 0.005

    var sourceCIImage:CIImage?
    var finalCIImage:CIImage?
    
    var ciContext:CIContext?
    
    @IBOutlet var imageView:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(stepTime))


        sourceCIImage = CIImage(image: img1!)
        finalCIImage = CIImage(image: img2!)
        
        ciContext = CIContext()
    }

    @IBAction func resetAction(_ sender: AnyObject) {
        imageView.image = img1
    }

    @IBAction func testFilterAction(_ sender: AnyObject) {
//        imageView.image = img2
        
        imageView.image = img1
        time = 0.0
        displayLink?.add(to: RunLoop.current,
                         forMode: RunLoop.Mode.default)
    }
    
    func dissolveFilter(_ inputImage: CIImage,
                        to targetImage: CIImage,
                        time: TimeInterval) -> CIImage? {
        
        let inputTime = simd_smoothstep(0, 1, time)
        
        guard let filter = CIFilter(name:"CIDissolveTransition",
                                    parameters:
            [
                kCIInputImageKey: inputImage,
                kCIInputTargetImageKey: targetImage,
                kCIInputTimeKey: inputTime
            ]) else {
                return nil
        }
        
        return filter.outputImage
    }
    
    func pixelateFilter(_ inputImage: CIImage, time: TimeInterval) -> CIImage? {
        
        let inputScale = simd_smoothstep(1, 0, abs(time))
        
        guard let filter = CIFilter(name:"CIPixellate",
                                    parameters:
            [
                kCIInputImageKey: inputImage,
                kCIInputScaleKey: inputScale
            ]) else {
                return nil
        }
        
        return filter.outputImage
    }
    
    @objc
    func stepTime() {
        time += dt
        
        // End transition after 1 second
        if time > 1 {
            displayLink?.remove(from:RunLoop.main, forMode:RunLoop.Mode.default)
        } else {
            if let sourceCIImage = sourceCIImage,
                let finalCIImage = finalCIImage,
                let ciContext = ciContext
            {
                guard let dissolvedCIImage = dissolveFilter(sourceCIImage,
                                                            to:finalCIImage,
                                                            time:time) else {
                                                                return
                }
                guard let pixelatedCIImage = pixelateFilter(dissolvedCIImage,
                                                            time:time) else {
                                                                return
                }
                // imageView and ciContext are properties of the class.
                showCIImage(pixelatedCIImage, in:imageView, context:ciContext)
            } else {
                print("no image loaded")
            }
        }
    }
    
    func showCIImage(_ ciImage: CIImage,
                     in imageView: UIImageView,
                     context: CIContext) {
        
        guard let cgImage = context.createCGImage(ciImage,
                                                  from: ciImage.extent) else {
                                                    return
        }
        let uiImage = UIImage(cgImage:cgImage)
        
        imageView.image = uiImage
    }
}

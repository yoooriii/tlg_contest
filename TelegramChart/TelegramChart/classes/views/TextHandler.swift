//
//  TextHandler.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/14/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class TextHandler {
    func test1(view:UIView) {
//        view.layerUsesCoreImageFilters = true

        let textLayer = CATextLayer()
        textLayer.string = "Core Animation"
        textLayer.foregroundColor = UIColor.blue.cgColor
        textLayer.backgroundColor = UIColor.lightGray.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.fontSize = 100
        textLayer.frame = CGRect(x: 10, y: 10, width: 700, height: 140)

//        let filterName = "CIPointillize"
        let filterName = "CICheckerboardGenerator"
        let parameters = [String:Any]()//["inputRadius": 6]
        if let filter = CIFilter(name: filterName,
                                 parameters: parameters) {
            textLayer.filters = [filter]
//            view.layer.filters = [filter]
        }
        view.layer.addSublayer(textLayer)

        let l2 = CALayer()
        l2.backgroundColor = UIColor.red.cgColor
        l2.frame = CGRect(x:20, y: 200, width: 200, height: 200)
        let data = "Hello world".data(using: .utf8)
        if let f2 = CIFilter(name: "CIQRCodeGenerator") {
            f2.setValue(data!, forKey: "inputMessage")
            l2.filters = [f2]
            //            view.layer.filters = [filter]
        }

        view.layer.addSublayer(l2)
    }

    func test2() {
        let inputImage = UIImage(named: "taylor-swift")!
        let context = CIContext(options: nil)

        if let currentFilter = CIFilter(name: "CISepiaTone") {
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)

            if let output = currentFilter.outputImage {
                if let cgimg = context.createCGImage(output, from: output.extent) {
                    let processedImage = UIImage(cgImage: cgimg)
                    // do something interesting with the processed image
                }
            }
        }
    }


}

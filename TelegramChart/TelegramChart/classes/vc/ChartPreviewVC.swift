//
//  ChartPreviewVC.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/20/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class ChartPreviewVC: UIViewController {
    @IBOutlet weak var chartPreview: ChartTiledView!
    private var planeIndex = -1
    var selectedIndex:Int { set { planeIndex = newValue } get { return planeIndex } }
    var graphicsContainer:GraphicsContainer? {
        didSet {
            if let graphicsContainer = graphicsContainer {
                planeIndex = (graphicsContainer.planes.count > 0) ? 0 : -1
            } else { planeIndex = -1 } }
    }
    var zoomH:Double=1.0, zoomV:Double=1.0, moveH:Double=0.0
    var lineWidth:CGFloat = 2.0
    var logicCanvas:LogicCanvas?
    let contentWidth = CGFloat(3000.0)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPlane(index: planeIndex)
    }

    private func scaleRangeValue(_ min:Double, _ max:Double, _ val:Double) -> Double {
        return min + val * (max-min)
    }

    @IBAction func actZoomH(_ sender: UISlider) {
        let val = Double(sender.value)
        zoomH = scaleRangeValue(0.3, 3.0, val)
        print("ZH: \(String(format: "%2.2f", zoomH))")

        updateMx(x: CGFloat(moveH), h: CGFloat(zoomH), v: CGFloat(zoomV))
    }

    @IBAction func actZoomV(_ sender: UISlider) {
        let val = Double(sender.value)
        zoomV = scaleRangeValue(0.3, 3.0, val)
//        print("ZV: \(String(format: "%2.2f", zoomV))")

        updateMx(x: CGFloat(moveH), h: CGFloat(zoomH), v: CGFloat(zoomV))
    }

    @IBAction func actMoveH(_ sender: UISlider) {
        let val = Double(sender.value)
        moveH = scaleRangeValue(0.0, Double(contentWidth), val)
//        print("MH: \(String(format: "%2.2f", moveH))")

        updateMx(x: CGFloat(moveH), h: CGFloat(zoomH), v: CGFloat(zoomV))
    }

    private func updateMx(x:CGFloat, h:CGFloat, v:CGFloat) {
        let tt0 = CGAffineTransform(scaleX: h, y: v)
        let tt2 = CGAffineTransform(translationX: -x, y: 0)
        let tt3 = tt0.concatenating(tt2)
        chartPreview.transform = tt3
//        chartPreview.setNeedsDisplay()
    }

    private func showPlane(index:Int) {
        guard let container = graphicsContainer  else {
            print("no graphicsContainer")
            return
        }

        let plCount = container.size
        if index < 0 || index >= plCount {
            print("wrong index \(index)")
            return
        }

        let plane = container.planes[index]

        // new logic canvas, create and init
        logicCanvas = LogicCanvas(plane: plane)
        logicCanvas!.lineWidth = self.lineWidth
        let height = chartPreview.frame.height - 5.0
        let width = contentWidth//chartPreview.frame.width
        logicCanvas!.viewSize = CGSize(width:contentWidth, height:height)
        logicCanvas!.tileRect = CGRect(x:0, y:-2.0, width:width, height:height)

        //let p3d = logicCanvas!.createPlane3d()

        let slice = logicCanvas!.getSlice(at: 0)
        chartPreview.slice = slice
    }

}

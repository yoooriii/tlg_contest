//
//  SliderBackgroundView.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

protocol ChartInterface {
    func setPlane(_ plane:Plane)
}

struct Plane2d {
    let vTime: VectorTime!
    let vAmplitude: VectorAmplitude!
    let color: UIColor?
}

extension Plane2d {
    func pathInRect(_ bounds:CGRect) -> CGPath {
        let plane2d = self
        // translations
        let tx:CGFloat = -CGFloat(plane2d.vTime.minValue)
        let ty:CGFloat = -CGFloat(plane2d.vAmplitude.minValue)
        // scales
        let dx = CGFloat(plane2d.vTime.maxValue - plane2d.vTime.minValue)
        let dy = CGFloat(plane2d.vAmplitude.maxValue - plane2d.vAmplitude.minValue)
        let sx:CGFloat = dx/bounds.width
        let sy:CGFloat = dy/bounds.height

        let tSize = plane2d.vTime.values.count
        let aSize = plane2d.vAmplitude.values.count
        // !! both sizes must be equal, using min just in case
        let count = min(tSize, aSize)
        let path = CGMutablePath()

        for i in 0..<count {
            let x0 = CGFloat(plane2d.vTime.values[i])
            let y0 = CGFloat(plane2d.vAmplitude.values[i])
            let x = (x0 + tx) / sx
            let y = bounds.height - ((y0 + ty) / sy) // up side down y
            let pt = CGPoint(x:x, y:y)
            if 0 == i {     path.move(to: pt) }
            else {          path.addLine(to: pt) }
        }

        return path
    }
}

class BGLayer: CALayer {
    private var graphLayers = [CAShapeLayer]()

    func awake() {
        let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.magenta]
        for i in 0..<5 {
            let sbLayer = CAShapeLayer()
            graphLayers.append(sbLayer)
            self.addSublayer(sbLayer)

            sbLayer.borderColor = colors[i].cgColor
            sbLayer.strokeColor = colors[i].cgColor
            sbLayer.cornerRadius = CGFloat(i*2 + 3)
            sbLayer.borderWidth = 1
            sbLayer.backgroundColor = UIColor.clear.cgColor
        }
        setNeedsLayout()
    }

    override func layoutSublayers() {
        for gl in graphLayers {
            gl.frame = self.bounds
        }
    }

    func setPlane(_ plane:Plane) {
//        self.plane = plane

        let ampCount = plane.vAmplitudes.count
        let layCount = graphLayers.count
        if ampCount > layCount {
            print("some charts won't show [\(ampCount) > \(layCount)]")
        }
        for i in 0..<layCount {
            let layer = graphLayers[i]
            if i < ampCount {
                let amp = plane.vAmplitudes[i]
                let p2d = Plane2d(vTime: plane.vTime, vAmplitude:amp, color:amp.color)
                layer.isHidden = false
                setPlane2d(p2d, on:layer)
            } else {
                // hide unused layers
                layer.isHidden = true
            }
        }
    }

    private func setPlane2d(_ plane2d:Plane2d, on shapeLayer:CAShapeLayer) {
        var rect = self.bounds
        rect.origin = CGPoint(x:rect.width/2, y:rect.height/2)

        let path = plane2d.pathInRect(rect)
        shapeLayer.path = path
        shapeLayer.strokeColor = (plane2d.color ?? UIColor.black).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
    }
}

class SliderBackgroundView: UIView, ChartInterface {
    private var plane:Plane?
    private var graphs = [SimpleGraphView]()
    private var sublayers = [CAShapeLayer]()

    override class var layerClass: AnyClass { return BGLayer.self }

    override func awakeFromNib() {
        bgLayer?.awake()
    }

    var shapeLayer: CAShapeLayer? {
        return self.layer as? CAShapeLayer
    }

    var bgLayer: BGLayer? {
        return self.layer as? BGLayer
    }

    func setPlane(_ plane:Plane) {
        self.plane = plane
        self.bgLayer?.setPlane(plane)
//        updateView()
    }

//    private func updateView() {
//        if let plane = plane, let amplitudes = plane.vAmplitudes {
//            let d = amplitudes.count - graphs.count
//            if d > 0 {
//                // add a few additional graphs
//                addGraphs(d)
//            } else if d < 0 {
//                // remove a few not needed graphs
//                for _ in d..<0 {
//                    graphs.last?.removeFromSuperview()
//                }
//            }
//
//            // populate graphs with models
//            var i = 0
//            for g in graphs {
//                let p2d = Plane2d(vTime: plane.vTime, vAmplitude:amplitudes[i])
//                g.setPlane2d(p2d)
//                i += 1
//            }
//        } else {
//            // no plane, remove all graphs
//            for g in graphs {
//                g.removeFromSuperview()
//            }
//        }
//    }


    private func addGraphs(_ count:Int) {
        for _ in 0..<count {
            let graph = SimpleGraphView()
            graphs.append(graph)
            self.addSubview(graph)
        }
    }

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)

        if let graph = subview as? SimpleGraphView {
            if let indx = graphs.firstIndex(of: graph) {
                graphs.remove(at:indx)
            }
        }
    }

}

class SimpleGraphView: UIView {
    override class var layerClass: AnyClass { return CAShapeLayer.self }

    var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }

    func setPlane2d(_ plane2d:Plane2d) {
        print("SimpleGraphView:setPlane2d: \(plane2d)")
    }
}

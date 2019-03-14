//
//  ViewController.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
    @IBOutlet var sliderView: ScaleSliderView!
    @IBOutlet var chartView:ChartView!
    @IBOutlet var infoLabel:UILabel!

    var nextIndex = -1
    var graphicsContainer:GraphicsContainer?

    override func viewDidLoad() {
        super.viewDidLoad()
        sliderView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        let vvv = TextHandler()
//        vvv.test1(view:self.view)
    }

    @IBAction func loadData(_ sender: AnyObject) {
        print("load")
        let url = Bundle.main.url(forResource: "chart_data", withExtension: "json")
        if let url = url { do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            do {
                graphicsContainer = try decoder.decode(GraphicsContainer.self, from: jsonData)
                print("graphicsContainer: \(graphicsContainer)")
                nextIndex = 0
                showPlane(index: 0)
            } catch {
                print("cannot decode json")
            }
        } catch {
            print("cannot read file at \(url)")
            } } else {
            print("no json")
        }

    }

    @IBAction func showNextPlane(_ sender: AnyObject) {
        self.showPlane(index: nextIndex)
        nextIndex += 1
        if let container = graphicsContainer {
            let plCount = container.planes.count
            if nextIndex >= plCount {
                nextIndex = 0
            }
        } else {
            nextIndex = -1
        }
    }

    func showPlane(index:Int) {
        if let container = graphicsContainer {
            let plCount = container.planes.count
            if index < 0 || index >= plCount {
                print("wrong index \(index)")
                infoLabel.text = "wrong index \(index)"
                return
            }

            var infoTxt = "#[\(index):\(container.planes.count)]: "
            let plane = container.planes[index]
            // convert plane to Plane3d
            // debug size & origin
            let bounds = CGRect(x:100, y:100, width:1000, height:1000)
            var arrP2d = [Plane2d]()
            for amp in plane.vAmplitudes {
                var p2d = Plane2d(vTime: plane.vTime, vAmplitude:amp)
                p2d.color = amp.color
                p2d.bounds = bounds
                p2d.path = p2d.pathInRect(bounds)
                arrP2d.append(p2d)

                infoTxt += "\(amp.values.count) "
            }
            let p3d = Plane3d(planes:arrP2d)
            sliderView.setPlane3d(p3d)
            chartView.setPlane3d(p3d)

            infoLabel.text = infoTxt


        } else {
            print("no graphicsContainer")
            infoLabel.text = "no graphicsContainer"
        }


    }

}

extension ChartViewController: ScaleSliderViewDelegate {
    func sliderDidChange(_ slider:ScaleSliderView, position:CGFloat) {
        infoLabel.text = "slider pos  [p:z]=[\(String(format:"%f2.1", slider.getPosition()*100.0)) : \(String(format:"%f2.1", slider.getZoom()*100.0))]"
    }

    func sliderDidChange(_ slider:ScaleSliderView, zoom:CGFloat) {
        infoLabel.text = "slider pos  [p:z]=[\(String(format:"%f2.1", slider.getPosition()*100.0)) : \(String(format:"%f2.1", slider.getZoom()*100.0))]"
    }
}

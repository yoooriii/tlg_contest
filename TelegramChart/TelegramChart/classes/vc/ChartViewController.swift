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
    let MASTER_SIZE = CGSize(width:1000, height:1000)

    override func viewDidLoad() {
        super.viewDidLoad()
        sliderView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        let vvv = TextHandler()
//        vvv.test1(view:self.view)
        self.test4()
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
            let bounds = CGRect(x:0, y:0, width:1000, height:1000)
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
            setPlane3d(p3d)

            infoLabel.text = infoTxt


        } else {
            print("no graphicsContainer")
            infoLabel.text = "no graphicsContainer"
        }


    }

    func setPlane3d(_ p3d:Plane3d) {
        sliderView.setPlane3d(p3d)
        chartView.setPlane3d(p3d)
        setScrollPlane3d(p3d)
        contentLayer?.setPlane3d(p3d)
        hostLayer?.display()
    }


////////////////
    var scrollLayer:CAScrollLayer?
    func test1() {
        //        let scale = UIScreen.main.scale

        let scrLayer = CAScrollLayer()
        scrLayer.borderColor = UIColor.red.cgColor
        scrLayer.backgroundColor = UIColor.yellow.cgColor
        scrLayer.borderWidth = 1
        scrLayer.frame = CGRect(x:10, y:100, width:300, height:300)
        scrLayer.scrollMode = .both

        let tileSize = CGSize(width:64, height:64)
        for iy in 0..<8 {
            for ix in 0..<8 {
                let tile = CALayer()
                let origin = CGPoint(x:tileSize.width * CGFloat(ix), y:tileSize.height * CGFloat(iy))
                tile.frame = CGRect(origin:origin, size: tileSize)
                tile.backgroundColor = UIColor.random().cgColor
                tile.name = "kTile_\(iy)_\(ix)"

                scrLayer.addSublayer(tile)
            }
        }

        view.layer.addSublayer(scrLayer)
        scrollLayer = scrLayer
    }

    var chartMultiShapeLayers = [ChartMultiShapeLayer]()
    func test2() {
        let WIDTH = CGFloat(300)
        let HEIGHT = CGFloat(300)

        let scrLayer = CAScrollLayer()
        scrLayer.borderColor = UIColor.red.cgColor
        scrLayer.backgroundColor = UIColor.yellow.cgColor
        scrLayer.borderWidth = 1
        scrLayer.frame = CGRect(x:10, y:100, width:WIDTH, height:HEIGHT)
        scrLayer.scrollMode = .horizontally

        let tileSize = CGSize(width:256, height:256)
        for ix in 0..<8 {
            let testLayer = ChartMultiShapeLayer()
            testLayer.borderColor = UIColor.red.cgColor
            testLayer.backgroundColor = UIColor.clear.cgColor
            testLayer.borderWidth = 1
            let x = CGFloat(ix) * tileSize.width
            testLayer.frame = CGRect(x:x, y:0, width:tileSize.width, height:HEIGHT)
            testLayer.name = "kTile_\(ix)"

            scrLayer.addSublayer(testLayer)
        }

        view.layer.addSublayer(scrLayer)
        scrollLayer = scrLayer
    }

    var hostLayer:CALayer?
    var contentLayer:ChartMultiShapeLayer?
    func test3() {
        let hostL = CALayer()
        hostL.frame = CGRect(x:10, y:100, width:350, height:250)
        hostL.backgroundColor = UIColor.yellow.cgColor
        hostL.borderColor = UIColor.red.cgColor
        hostL.borderWidth = 1.0

        let contentL = CAShapeLayer()//ChartMultiShapeLayer()
        //        contentLayer = contentL
        contentL.frame = CGRect(x:0, y:0, width:1024, height:250)
        contentL.backgroundColor = UIColor.green.cgColor
        contentL.path = createTestPath()
        contentL.lineWidth = 1.0
        contentL.strokeColor = UIColor.blue.cgColor
        contentL.fillColor = UIColor.clear.cgColor

        hostL.addSublayer(contentL)
        hostL.contentsRect = CGRect(x:0, y:0, width:350, height:250)

        hostLayer = hostL
        self.view.layer.addSublayer(hostL)
    }

    func createTestPath() -> CGPath {
        let path = CGMutablePath()
        var pt = CGPoint.zero
        let size = MASTER_SIZE//CGSize(width:1000, height:1000)
        let count = 100
        let w0 = size.width / CGFloat(count)
        for ix in 0..<count {
            if 0 == ix {
                path.move(to: pt)
            } else {
                pt.y = (0 == ix & 1) ? 0 : size.height
                pt.x = CGFloat(ix) * w0
                path.addLine(to: pt)
            }
        }

        // add text
        let th = TextHandler()
        let txt1 = NSAttributedString(string: "Hello world of charts", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 100)])
        let txtPath1 = th.createTextPath(string: txt1)
        let tt1 = CGAffineTransform(scaleX: 1, y: 4)
        let tt2 = tt1.translatedBy(x: 0, y:75)
        path.addPath(txtPath1, transform:tt2)

        let txt2 = NSAttributedString(string: "Quick brown fox jumped", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 100)])
        let txtPath2 = th.createTextPath(string: txt2)
        let tt3 = tt1.translatedBy(x: 0, y:150)
        path.addPath(txtPath2, transform:tt3)

        let box = path.boundingBox
        print("box \(Int(box.minX)), \(Int(box.minY)) { \(Int(box.width)) x \(Int(box.height)) }")

        return path
    }

    var scrollContent = [CAShapeLayer]()
    var scrollWidth: CGFloat {
        get { return 0 == scrollContent.count ? 0 :
            CGFloat(scrollContent.count) * scrollContent[0].frame.width - CGFloat(50) }
    }

    func test4() {
        scrollLayer = CAScrollLayer()
        if let scrollLayer = scrollLayer {
            scrollContent.removeAll() // just in case

            let masterPath = createTestPath()
            scrollLayer.frame = CGRect(x:10, y:300, width:350, height:250)
            scrollLayer.backgroundColor = UIColor.darkGray.cgColor
            scrollLayer.isGeometryFlipped = true
            let tileSize = CGSize(width:100, height:250)
            let count = 20

            let colors = [UIColor.red, UIColor.green, UIColor.blue]
            let contentWidth = CGFloat(1300) //CGFloat(count) * tileSize.width
            let tt0 = CGAffineTransform(scaleX: contentWidth/MASTER_SIZE.width, y: 250.0 / MASTER_SIZE.height)

            for ix in 0..<count {
                let tile = CAShapeLayer()
                let x = CGFloat(ix) * tileSize.width
                let color = colors[ix % colors.count]

                tile.frame = CGRect(x:x, y:0, width:tileSize.width, height:250)
                tile.backgroundColor = UIColor.clear.cgColor//color.cgColor
                tile.strokeColor = color.cgColor
                tile.fillColor = UIColor.clear.cgColor
                tile.lineWidth = 1.5
                tile.borderColor = color.cgColor
                tile.borderWidth = 2.0
                tile.masksToBounds = true
                tile.name = "kTile_\(ix)"
                scrollContent.append(tile)

//                var tt = CGAffineTransform(translationX: -x, y: CGFloat(ix))
//                var tt2 = tt.scaledBy(x: 0.9, y: 0.2)
                let tx = -x//(x + tileSize.width)
                let tt4 = CGAffineTransform(translationX: tx, y: 0)
                //var tt3 = tt0.translatedBy(x: tx, y: 0)
                var tt3 = tt0.concatenating(tt4)
                let path = masterPath.copy(using:&tt3)
                tile.path = path

                scrollLayer.addSublayer(tile)
            }

            self.view.layer.addSublayer(scrollLayer)
        }

    }

    func setScrollPlane3d(_ p3d:Plane3d) {
        if let scrollLayer = scrollLayer {
            if p3d.planes.count > 0 && scrollContent.count > 0 {
                let masterPath = CGMutablePath()
                for p2d in p3d.planes {
                    if let path = p2d.path {
                        masterPath.addPath(path)
                    }
                }
                let tileSize = scrollContent[0].frame.size
                let tt0 = CGAffineTransform(scaleX: scrollWidth/1000.0, y: 250.0 / 1000.0)

                if true {
                    var tx = CGFloat(0)
                    for tile in scrollContent {
                        let tt4 = CGAffineTransform(translationX: tx, y: 0)
                        //var tt3 = tt0.translatedBy(x: tx, y: 0)
                        var tt3 = tt0.concatenating(tt4)
                        let path = masterPath.copy(using:&tt3)
                        tile.path = path

                        tx -= tileSize.width
                    }
                }

            }
        }
    }

    ////////////////////////////////////////
    @IBAction func sliderDidMove(_ slider: UISlider) {
        moveScroll(CGFloat(slider.value))
    }

    private func moveScroll(_ value:CGFloat) {
        let x = CGFloat(value * 2000.0)
        let pt = CGPoint(x:x, y:0)
        if let scrollLayer = scrollLayer {
            scrollLayer.scroll(to:pt)
            scrollLayer.removeAllAnimations()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "kCollection" {
            if let vc = segue.destination as? CollectionVC2 {
                vc.graphicsContainer = self.graphicsContainer
            }
        }
    }


}

extension ChartViewController: ScaleSliderViewDelegate {
    func sliderChanging(_ slider: ScaleSliderView) {
        infoLabel.text = "slider changing  [p:z]=[\(String(format:"%f2.1", slider.getPosition()*100.0)) : \(String(format:"%f2.1", slider.getZoom()*100.0))]"

        moveScroll(slider.getPosition())
    }

    func sliderDidChange(_ slider:ScaleSliderView, position:CGFloat) {
        infoLabel.text = "slider pos  [p:z]=[\(String(format:"%f2.1", slider.getPosition()*100.0)) : \(String(format:"%f2.1", slider.getZoom()*100.0))]"

        moveScroll(slider.getPosition())
    }

    func sliderDidChange(_ slider:ScaleSliderView, zoom:CGFloat) {
        infoLabel.text = "slider zoom [p:z]=[\(String(format:"%f2.1", slider.getPosition()*100.0)) : \(String(format:"%f2.1", slider.getZoom()*100.0))]"

        moveScroll(slider.getPosition())
    }
}

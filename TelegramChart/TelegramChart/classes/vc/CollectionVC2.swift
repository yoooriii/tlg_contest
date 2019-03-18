//
//  CollectionVC2.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/15/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class CollectionVC2: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var sliderPosition: UISlider!
    @IBOutlet var sliderZoom: UISlider!
    @IBOutlet var infoLabel: UILabel!

    @IBOutlet var sliderCollectionView: UICollectionView!
    var scrollController: ScrollController!
    var planeIndex = -1
    var graphicsContainer:GraphicsContainer? {
        didSet {
            if let graphicsContainer = graphicsContainer {
                planeIndex = (graphicsContainer.planes.count > 0) ? 0 : -1
            } else { planeIndex = -1 } }
    }
    let tileWidth = CGFloat(128)
    // this is not exactly contentSize.width (usually it is a bit smaller in order to accept an integer number of tiles)
    let contentWidth = CGFloat(3000)
    // chart line (stroke) width
    let lineWidth = CGFloat(5.0)
    private var logicCanvas: LogicCanvas?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width:tileWidth, height:collectionView.frame.height)
            print("layout: \(layout)")
        }

        scrollController = ScrollController(collectionView:sliderCollectionView, delegate:self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNextPlane()
    }

    @IBAction func switchPlane(_ sender: UIButton) {
        print("switchPlane \(planeIndex)")
        showNextPlane()
    }

    @IBAction func goBack(_ sender: UIButton) {
        print("back")
        dismiss(animated: true) {
            print("dismissed")
        }
    }

    @IBAction func sliderChangeAction(_ sender: UISlider) {
        let value = CGFloat(sender.value)
        if sender == sliderPosition {
            chartVerticalOffset = (value - 0.5) * 1000
        }
        else if sender == sliderZoom {
            chartVerticalZoom = value * 2.5 + 0.5
        }
        updateZoom()
    }

    private func sliderChange(position:CGFloat, zoom:CGFloat) {
        self.chartVerticalZoom = zoom * 2.5 + 0.5
        print("on slider change: \(Int(position * 100.0)) : \(Int(zoom * 100.0))")
   //     updateZoomInTiles()
        updateZoom()
    }

    private var chartVerticalZoom = CGFloat(1)
    private var chartVerticalOffset = CGFloat(0)

    private func updateZoom() {
        let iItems = collectionView.indexPathsForVisibleItems
        for iPath in iItems {
            let item = collectionView.cellForItem(at: iPath)
            if let item = item as? ChartTileCell {
                item.setVertical(zoom:chartVerticalZoom, offset:chartVerticalOffset)
            }
        }
    }



//    private func updateZoomInTiles() {
//        guard let planes = plane3d?.planes else {
//            // no data models, nothing to show
//            return
//        }
//
//        let cells = collectionView.visibleCells
//        for cell in cells {
//            let tc = cell as UICollectionReusableView
//            if let tileCell = tc as? ChartTileCell {
//                let indexPath = collectionView.indexPath(for: cell)
//                let ix = CGFloat(indexPath!.item)
//                let offsetX = ix * tileWidth
////                print("idx: \(ix, offsetX)")
//
//                let MASTER_SIZE = CGSize(width:1000, height:1000)
//                let height = collectionView.frame.height - 2.0
//                let tt0 = CGAffineTransform(scaleX: contentWidth/MASTER_SIZE.width, y: height/MASTER_SIZE.height * chartVerticalZoom)
//                let tt4 = CGAffineTransform(translationX: -offsetX, y: 0)
//                var tt3 = tt0.concatenating(tt4)
//
//                var pathModels = [PathModel]()
//                for p2d in planes {
//                    let masterPath = p2d.path!
//                    let tilePath = masterPath.copy(using:&tt3)
//                    let pm = PathModel(path:tilePath, color:p2d.color ?? UIColor.black, lineWidth:lineWidth)
//                    pathModels.append(pm)
//                }
//                tileCell.setPathModels(pathModels)
//            } else {
//                print("wrong cell class \(cell)")
//            }
//        }
//    }

    private func showNextPlane() {
        showPlane(index: planeIndex)
        planeIndex += 1
        if let container = graphicsContainer {
            let plCount = container.planes.count
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

        let plCount = container.planes.count
        if index < 0 || index >= plCount {
            print("wrong index \(index)")
            infoLabel.text = "wrong index \(index)"
            return
        }

        var infoTxt = "#[\(index):\(container.planes.count)]: "
        let plane = container.planes[index]


        // new logic canvas, create and init
        logicCanvas = LogicCanvas(plane: plane)
        logicCanvas!.lineWidth = self.lineWidth
        let height = collectionView.frame.height - 5.0
        logicCanvas!.viewSize = CGSize(width:contentWidth, height:height)
        logicCanvas!.tileRect = CGRect(x:0, y:-2.0, width:tileWidth, height:height)

        let p3d = logicCanvas!.createPlane3d()
        scrollController.setPlane3d(p3d)
        infoTxt += "; count:\(logicCanvas!.count)"
        infoLabel.text = infoTxt
        collectionView.reloadData()
    }
}

extension CollectionVC2: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(ceil(contentWidth/tileWidth))
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"kTile", for:indexPath)
        cell.backgroundColor = UIColor.lightGray

        guard let tileCell = cell as? ChartTileCell else {
            print("wrong cell class \(cell)")
            return cell
        }
        tileCell.titleLabel?.text = "\(indexPath.section):\(indexPath.item)"

        guard let canvas = logicCanvas else {
            // no data models, nothing to show
            return cell
        }

        tileCell.slice = canvas.getSlice(at:indexPath.item)
        return cell
    }
}

extension CollectionVC2: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let indices = collectionView.indexPathsForVisibleItems
        var yy = Set(indices)
        yy.insert(indexPath)
        let mmm = yy.map { (ip) -> Int in
            return ip.item
        }

        if let logicCanvas = logicCanvas {
            if let xtrm = logicCanvas.getExtremum(mmm) {

                let offsetY = -logicCanvas.pointsFrom(normalY: xtrm.min)
                let zoom = 1000.0/(xtrm.max - xtrm.min)

                print("current xtrm: [\(Int(xtrm.min)):\(Int(xtrm.max))]; offs:\(offsetY); zoom:\(zoom)")

                for ip in yy {
                    if let cell = collectionView.cellForItem(at: ip) as? ChartTileCell {
                        cell.setVertical(zoom: zoom, offset: offsetY)
                    }
                }
            } else {
                print("no xtrm")
            }


        }


//        if let tileCell = cell as? ChartTileCell {
//            if let xtrY = tileCell.getExtremumY() {
//                print("xtremum at \(indexPath.item): \(xtrY)")
//            }
//        }
    }
}

extension CollectionVC2: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // update slider from scroll
        let pt = scrollView.contentOffset
        let sz = scrollView.contentSize
        let w0 = scrollView.frame.width
        if sz.width > w0 {
            let w = sz.width - w0
            let v = pt.x / w
            sliderPosition.value = Float(v)
        }
    }
}

extension CollectionVC2: ScrollControllerDelegate {
    func scrollControllerDidScroll(_ scrollController: ScrollController, range: VectorRange) {
        print("scroll range: \(Int(range.position)):\(Int(range.length))")
    }

    func scrollControllerDidScroll(_ scrollController: ScrollController, value: CGFloat) {
        let www = collectionView.contentSize.width - collectionView.frame.width
        let offset = CGPoint(x:www * value, y:0)
        collectionView.setContentOffset(offset, animated: false)
    }
}

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
    private var planeIndex = -1
    var selectedIndex:Int { set { planeIndex = newValue } get { return planeIndex } }
    var graphicsContainer:GraphicsContainer? {
        didSet {
            if let graphicsContainer = graphicsContainer {
                planeIndex = (graphicsContainer.planes.count > 0) ? 0 : -1
            } else { planeIndex = -1 } }
    }
    // original tile width for horizontal scale factor 1.0
    let tileWidth = CGFloat(128)
    // this is not exactly contentSize.width (usually it is a bit smaller in order to accept an integer number of tiles)
    let contentWidth = CGFloat(3000)
    // chart line (stroke) width
    let lineWidth = CGFloat(5.0)
    private var logicCanvas: LogicCanvas?
    private var lastUpdOffsetX = CGFloat(0)

    ///
    var timeModels = [TimeMarkModel]()

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd'\n'YYYY"
        return formatter
    }()

    private func timeString(_ value:Int64) -> String {
        let timestamp = Date(timeIntervalSince1970:TimeInterval(value)/1000.0)
        let dateString = dateFormatter.string(from:timestamp)
        return dateString
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.isHidden = true
        if let layout = collectionView.collectionViewLayout as? ChartFlowLayout {
            layout.registerDecorations()
        }

        scrollController = ScrollController(collectionView:sliderCollectionView, delegate:self)
    }

//    override func viewDidLayoutSubviews() {
//        updateCanvasSize()
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width:tileWidth, height:tileHeight())
        }
        collectionView.isHidden = false
        showNextPlane()
    }

    @IBAction func actGetVisibleItems(_ sender: UIButton) {
        let ip = IndexPath(item: 2000, section: 0)

        let qqq = collectionView.visibleSupplementaryViews(ofKind: "UICollectionElementKindSectionHeader")
        print("visible sv 1 \(qqq)")

        let www = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: DecorationKind.detailed.rawValue)
        print("visible sv 2 \(www)")

        let layout = collectionView.collectionViewLayout
        let cx = UICollectionViewFlowLayoutInvalidationContext()
        cx.invalidateDecorationElements(ofKind: DecorationKind.detailed.rawValue, at: [ip])
        layout.invalidateLayout(with: cx)
    }

    var debugN = 0
    var pos = CGFloat(100)
    @IBAction func reloadItem0(_ sender: UIButton) {
        guard let layout = collectionView.collectionViewLayout as? ChartFlowLayout else { return }
        if var model = layout.getDecorationModel(at: 2000) {
            model.values = [DecorationModel.Value(string:"dbg \(debugN)", color:UIColor.red)]
            debugN += 1
            model.x = pos
            pos += 50
            layout.setDecorationModel(model, at: 2003)
        }
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

    private func scaleValue(_ val:Float, min:Float, max:Float) -> Float {
        return min + val * (max-min)
    }

    // change horizontal scale and compensate the x offset
    @IBAction func sliderWidthAction(_ sender: UISlider) {
        let value = scaleValue(sender.value, min: 0.2, max: 10.0)
        let w2 = CGFloat(value)*tileWidth
        let height = tileHeight()
        var offset = collectionView.contentOffset
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let w1 = flowLayout.itemSize.width
            flowLayout.itemSize = CGSize(width:w2, height:height)
            offset.x = offset.x * w2 / w1
            collectionView.contentOffset = offset
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


        // new logic canvas, create and init
        logicCanvas = LogicCanvas(plane: plane)
        logicCanvas!.lineWidth = self.lineWidth
        updateCanvasSize()

        let p3d = logicCanvas!.createPlane3d()
        scrollController.setPlane3d(p3d)
        infoTxt += "; count:\(logicCanvas!.count)"
        infoLabel.text = infoTxt
        updateTimeItems()
        collectionView.reloadData()
    }

    private func updateCanvasSize() {
        guard let logicCanvas = self.logicCanvas else { return }
        let height = tileHeight()
        logicCanvas.viewSize = CGSize(width:contentWidth, height:height)
        logicCanvas.tileRect = CGRect(x:0, y:-2.0, width:tileWidth, height:height)
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
        tileCell.titleLabel?.text = ""//\(indexPath.section):\(indexPath.item)"

        guard let canvas = logicCanvas else {
            // no data models, nothing to show
            return cell
        }

        tileCell.slice = canvas.getSlice(at:indexPath.item)
        cell.backgroundColor = UIColor.clear
        return cell
    }

    //TODO: test it
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "kSimpleHeader", for: indexPath)
        return header
    }
}

//TODO: dead code, remove it if not using
extension CollectionVC2: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        guard let layout = collectionView.collectionViewLayout as? ChartFlowLayout else { return }
        layout.willDisplaySupplementaryView(view, elementKind:elementKind, at:indexPath)
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
    //TODO: dead code, remove it if not using
    func scrollControllerDidScroll(_ scrollController: ScrollController, range: VectorRange) {
//        print("scroll range: \(Int(range.position)):\(Int(range.length)) - \(Int(collectionView.contentSize.width))")
    }

    func scrollControllerDidScroll(_ scrollController: ScrollController, value: CGFloat) {
        let www = collectionView.contentSize.width - collectionView.frame.width
        let offset = CGPoint(x:www * value, y:0)
        collectionView.setContentOffset(offset, animated: false)
        updateOnScrollH()
    }

    private func updateOnScrollH() {
        guard let logicCanvas = self.logicCanvas else {return}
        let currTileWidth = currentTileWidth()
        if currTileWidth < 1 { return }
        let zoomH = currTileWidth/tileWidth
        let contentWidth0 = collectionView.contentSize.width/zoomH
        let logicScaleH = contentWidth0/LogicCanvas.SIZE
        let multyScaleH = zoomH * logicScaleH
        let widthMargin = tileWidth/2.0
        var offsetX = collectionView.contentOffset.x/multyScaleH
        let dx = abs(lastUpdOffsetX - offsetX)
        if dx < 5 {
            // do not update it every too often
            return
        }
        lastUpdOffsetX = offsetX
        offsetX -= widthMargin
        if offsetX < 0.0 { offsetX = 0.0 }
        var lengthW = collectionView.frame.width/multyScaleH
        lengthW += 2.0*widthMargin
        if (offsetX + lengthW) > LogicCanvas.SIZE { lengthW = LogicCanvas.SIZE - offsetX }
        let range = Range(origin:offsetX, length:lengthW)
        // MinMax?
        if let minMax = logicCanvas.getLogicExtremum(in:range) {
            let minMaxMaster = logicCanvas.getMinMax()
            let prescaleVal = CGFloat(0.90) // upscale tiles if needed
            let scaleH = prescaleVal * (minMaxMaster.max - minMaxMaster.min) / (minMax.max - minMax.min)
            let translateH = -(minMax.min/scaleH) // move a tile downward
            //FIXIT: not the best way to enumerate cells even though the trick makes its job
            for v in collectionView.subviews {
                if let cell = v as? ChartTileCell {
                    cell.setVertical(zoom:scaleH, offset:translateH)
                }
            }
        }
    }



    struct TimeMarkModel {
        var index:Int
        var value:Int64
        var x:CGFloat
    }

    ///////////
    func updateTimeItems() {
        guard let logicCanvas = self.logicCanvas else { return }
        let timeItemWidth = CGFloat(100)
        let currTileWidth = currentTileWidth()
        if currTileWidth < 1 { return }
        let zoomH = currTileWidth/tileWidth
        let contentWidth0 = collectionView.contentSize.width/zoomH
        let logicScaleH = contentWidth0/LogicCanvas.SIZE
        let multyScaleH = zoomH * logicScaleH

        let timeItemPeriodMin = CGFloat(120)
        let timesCount = ceil((collectionView.contentSize.width - timeItemWidth)/timeItemPeriodMin)
        let realPeriodX = (collectionView.contentSize.width - timeItemWidth)/timesCount
        let w2 = timeItemWidth
        //        for x in
        let strd = stride(from:w2, to:(collectionView.contentSize.width - w2), by:realPeriodX)
        let vTime = logicCanvas.getVectorTime()
        let vtmCount = vTime.count
        let ixScale = CGFloat(vtmCount)/LogicCanvas.SIZE
        var array = [TimeMarkModel]()
        var index = 0
        for x in strd {
            let logicX = x/multyScaleH
            let ix = logicX*ixScale
            let ixMin = Int(floor(ix))
            let nextTimeVal = vTime.values[ixMin]

            let model = TimeMarkModel(index:ixMin, value:nextTimeVal, x:x)
            array.append(model)

//            let ixMax = Int(ceil(ix))
//            let val = vTime.fromNormal(Double(logicX))

            index += 1
        }
        timeModels.removeAll()
        timeModels.append(contentsOf: array)

        reloadTimeModels()
    }

    private func reloadTimeModels() {
        guard let layout = collectionView.collectionViewLayout as? ChartFlowLayout else { return }
        var decorationModels = [DecorationModel]()
        for tm in timeModels {
            let decor = DecorationModel(x: tm.x, title:timeString(tm.value), color:UIColor.lightGray)
            decorationModels.append(decor)
        }

        layout.setDecorationModels(decorationModels)
    }

    // currentTileWidth vs tileWidth = variable vs const
    private func currentTileWidth() -> CGFloat {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return 0.0 }
        return flowLayout.itemSize.width
    }

    private func tileHeight() -> CGFloat {
        return collectionView.frame.height - 5.0
    }
}

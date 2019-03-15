//
//  CollectionVC.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/15/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class TileCell: UICollectionReusableView  /* UICollectionViewCell */ {
    override class var layerClass: AnyClass { return ChartTileLayer.self }

    var tileLayer: ChartTileLayer? {
        get { return layer as? ChartTileLayer }
    }

    override func prepareForReuse() {
        tileLayer?.clear()
    }

    func setPathModels(_ paths:[PathModel]?) {
        tileLayer?.setPathModels(paths)
    }
}

class CollectionVC: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var sliderPosition: UISlider!
    @IBOutlet var sliderZoom: UISlider!
    @IBOutlet var infoLabel: UILabel!

    var plane3d:Plane3d?
    var planeIndex = -1
    var graphicsContainer:GraphicsContainer? {
        didSet {
            if let graphicsContainer = graphicsContainer {
                planeIndex = (graphicsContainer.planes.count > 0) ? 0 : -1
            } else { planeIndex = -1 } }
    }
    let tileWidth = CGFloat(256)
    let contentWidth = CGFloat(2000)

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = collectionView.collectionViewLayout
        print("layout: \(layout)")
    }

    @IBAction func switchPlane(_ sender: UIButton) {
        print("switchPlane \(planeIndex)")

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

    @IBAction func goBack(_ sender: UIButton) {
        print("back")
        dismiss(animated: true) {
            print("dismissed")
        }
    }

    @IBAction func sliderChangeAction(_ sender: UISlider) {
        sliderChange(position: CGFloat(sliderPosition!.value), zoom: CGFloat(sliderZoom!.value))
    }

    private func sliderChange(position:CGFloat, zoom:CGFloat) {
        print("on slider change: \(Int(position * 100.0)) : \(Int(zoom * 100.0))")
    }

    private func showPlane(index:Int) {
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

    private func setPlane3d(_ p3d:Plane3d) {
        plane3d = p3d
        collectionView.reloadData()
    }
}

extension CollectionVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(ceil(contentWidth/tileWidth))
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"kTile", for:indexPath)
        cell.backgroundColor = UIColor.lightGray

        // cast up and down to get rid of warnings
        let tc:UICollectionReusableView = cell
        guard let planes = plane3d?.planes else {
            // no data models, nothing to show
            return cell
        }

        if let tileCell = tc as? TileCell {

            let ix = CGFloat(indexPath.item)
            let offsetX = ix * tileWidth
            print("idx: \(ix, offsetX)")

            let height = collectionView.frame.height - 2.0
            let tt0 = CGAffineTransform(scaleX: contentWidth/1000.0, y: height/1000.0)
            let tt4 = CGAffineTransform(translationX: -offsetX, y: 0)
            var tt3 = tt0.concatenating(tt4)

            var pathModels = [PathModel]()
            for p2d in planes {
                let masterPath = p2d.path!

                //TODO: transform the path
                

                let tilePath = masterPath.copy(using:&tt3)
                let pm = PathModel(path:tilePath, color:p2d.color ?? UIColor.black, lineWidth:2.0)
                pathModels.append(pm)
            }
            tileCell.setPathModels(pathModels)
        } else {
            print("wrong cell class \(cell)")
        }

        return cell
    }


}

//extension CollectionVC: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width:100, height:300)
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout
//        collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
//}

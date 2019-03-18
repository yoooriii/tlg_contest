//
//  ScrollController.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/17/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

class SliderHandleCell: UICollectionViewCell {
    static let id = "kSliderHandleCell"
    @IBOutlet weak var label: UILabel!
}

class SliderEmptyCell: UICollectionViewCell {
    static let id = "kSliderEmptyCell"
    @IBOutlet weak var label: UILabel!
}

@objc protocol ScrollControllerDelegate {
    /// value = [0...1]
    func scrollControllerDidScroll(_ scrollController:ScrollController, value:CGFloat)
    /// range normalized to 1000
    func scrollControllerDidScroll(_ scrollController:ScrollController, range:VectorRange)
}

class ScrollController: NSObject {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var delegate:ScrollControllerDelegate?

    private var sliderHeight = CGFloat(44)
    private let sliderHandleWidth = CGFloat(100)
    private var chartView: ChartView?

    init(collectionView: UICollectionView, delegate:ScrollControllerDelegate?) {
        super.init()
        self.collectionView = collectionView
        self.delegate = delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        updateContent()
    }

    private func updateContent() {
        sliderHeight = collectionView.frame.height
        if let _ = chartView {} else {
            self.chartView = ChartView()
            self.chartView?.awakeFromNib() //TODO: refactor wrong metyhod
            collectionView.backgroundView = self.chartView!
        }
    }

    func setPlane3d(_ p3d:Plane3d) {
        chartView?.setPlane3d(p3d)

        collectionView.reloadData()
    }
}

extension ScrollController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sliderWidth = collectionView.frame.width
        let size = (1 == indexPath.item) ? CGSize(width:sliderHandleWidth, height:sliderHeight) :
        CGSize(width:sliderWidth - sliderHandleWidth, height:sliderHeight)
        return size
    }

}

extension ScrollController: UICollectionViewDataSource {
    /// left to right: left empty item, slider handler, right empty item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell!
        if (1 == indexPath.item) {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier:SliderHandleCell.id, for: indexPath)
            cell.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier:SliderEmptyCell.id, for: indexPath)
            cell.backgroundColor = UIColor.clear
        }
        
        if let handle = cell as? SliderHandleCell {
            handle.label.text = "."
        }
        return cell
    }
}

extension ScrollController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // update slider from scroll
        let maxValue = CGFloat(1000) // scale constant
        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        let viewWidth = scrollView.frame.width
        var value = CGFloat(-1)
        if contentWidth > viewWidth {
            let scrollDistance = contentWidth - viewWidth
            var v = offsetX / scrollDistance
            // fix value when bouncing
//            if v < 0.0 { v = 0.0 }
//            else if v > 1 { v = 1.0 }
            value = 1.0-v
            delegate?.scrollControllerDidScroll(self, value: value)
//            sliderPosition.value = Float(v)

            // updated logic with VectorRange //TODO: remove the old delegate call
            let scrollDistance2 = scrollDistance + sliderHandleWidth
            let pos2 = viewWidth - offsetX - sliderHandleWidth
            let vrange = VectorRange(position: (pos2*maxValue/scrollDistance2), length: (sliderHandleWidth*maxValue/viewWidth))
            delegate?.scrollControllerDidScroll(self, range:vrange)
        }

        if let cell = collectionView.cellForItem(at: IndexPath(item: 1, section: 0)),
            let handle = cell as? SliderHandleCell {
            handle.label.text = /* (0 > value) ? "" : */ "\(Int(value * 100.0)) : \(Int(100.0*getWidthRatio()))"
        }
    }

    func getWidthRatio() -> CGFloat {
        let sliderWidth = collectionView.frame.width
        return sliderHandleWidth/sliderWidth
    }
}

//
//  ChartTileCell.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/17/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

class ChartTileCell: UICollectionViewCell /* UICollectionReusableView */ {
    override class var layerClass: AnyClass { return ChartTileLayer.self }

    @IBOutlet var titleLabel: UILabel?

    var tileLayer: ChartTileLayer? {
        get { return layer as? ChartTileLayer }
    }

    var slice:Slice? {
        didSet { updateSlice() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.layer.isGeometryFlipped = true
    }

    override func prepareForReuse() {
        tileLayer?.clear()
    }

    func setPathModels(_ paths:[PathModel]?) {
        tileLayer?.setPathModels(paths)
    }

    private func updateSlice() {
        guard let tileLayer = self.tileLayer else { return }
        if let slice = self.slice {
            tileLayer.setPathModels(slice.pathModels)
        } else {
            tileLayer.clear()
        }
    }

    func getExtremumY() -> MinMax? {
        return tileLayer?.getExtremumY()
    }

    func setVertical(zoom:CGFloat, offset:CGFloat) {
        tileLayer?.setVertical(zoom:zoom, offset:offset)
    }
}

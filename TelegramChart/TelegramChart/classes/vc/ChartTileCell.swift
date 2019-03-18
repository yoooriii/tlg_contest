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

    override func prepareForReuse() {
        tileLayer?.clear()
    }

    func setPathModels(_ paths:[PathModel]?) {
        tileLayer?.setPathModels(paths)
    }

    func getExtremumY() -> MinMax? {
        return tileLayer?.getExtremumY()
    }
}

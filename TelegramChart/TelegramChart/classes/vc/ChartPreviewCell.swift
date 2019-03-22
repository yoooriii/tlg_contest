//
//  ChartPreviewCell.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/20/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class ChartPreviewCell: UITableViewCell {
    static let id = "kChartPreviewCell"

    var slice:Slice? {
        didSet { updateSlice() }
    }

    override class var layerClass: AnyClass { return ChartTileLayer.self }

    @IBOutlet var titleLabel: UILabel?

    lazy var tileLayer: ChartTileLayer? = {
        { return self.layer as? ChartTileLayer }
        }()()

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.layer.isGeometryFlipped = true
    }

    override func prepareForReuse() {
        tileLayer?.clear()
        titleLabel?.text = ""
    }

    func setPathModels(_ paths:[PathModel]?) {
        tileLayer?.setPathModels(paths)
    }

    private func updateSlice() {
        guard let tileLayer = self.tileLayer else { return }
        if let slice = self.slice {
            tileLayer.setTileWidth(bounds.width)
            tileLayer.setPathModels(slice.pathModels)
        } else {
            tileLayer.clear()
        }
    }
}

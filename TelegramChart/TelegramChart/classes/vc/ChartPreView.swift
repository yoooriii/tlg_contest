//
//  ChartPreView.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/20/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

/// duplicates ChartPreviewCell
class ChartPreView: UIView {

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

    func setPathModels(_ paths:[PathModel]?) {
        tileLayer?.setPathModels(paths)
    }

    func clear() {
        tileLayer?.clear()
    }

    private func updateSlice() {
        guard let tileLayer = self.tileLayer else { return }
        if let slice = self.slice {
            tileLayer.setPathModels(slice.pathModels)
        } else {
            tileLayer.clear()
        }
    }
}

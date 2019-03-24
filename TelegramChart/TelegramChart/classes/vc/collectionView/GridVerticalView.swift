//
//  GridVerticalView.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/23/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

enum DecorationKind: String {
    case normal = "kGridVerticalView"
    case detailed = "kGridVerticalDetailView"
}

class GridVerticalDetailView: UICollectionReusableView {
    @IBOutlet var valueLabels: [UILabel]?
    @IBOutlet var verticalLine: UIView!
    private var model:DecorationModel?

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        print("GridVerticalDetailView apply layoutAttributes.")

        guard let attr = layoutAttributes as? DecorLayoutAttributes else { return }
        self.model = attr.model
        guard let model = attr.model else { return }
        guard let valueLabels = valueLabels, let modelValues = model.values else { return }
        var i = 0
        for label in valueLabels {
            if modelValues.count > i {
                let val = modelValues[i]
                label.text = val.string
                label.textColor = val.color
            } else {
                label.text = ""
            }
            i += 1
        }
        if let color = model.lineColor {
            verticalLine.backgroundColor = color
            verticalLine.isHidden = false
        } else {
            verticalLine.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
//        print("GridVerticalDetailView prepareForReuse.")
        clear()
    }

    private func clear() {
        if let valueLabels = valueLabels {
            for label in valueLabels {
                label.text = ""
            }
        }

//        layer.borderColor = UIColor.blue.cgColor
//        layer.borderWidth = 1.0
//        layer.cornerRadius = 25.0
    }
}

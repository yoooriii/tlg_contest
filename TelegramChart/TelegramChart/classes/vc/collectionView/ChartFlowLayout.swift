//
//  ChartFlowLayout.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/23/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit


// it uses GridVerticalView as a decoration view
class ChartFlowLayout: UICollectionViewFlowLayout {
    var itemModels = [Int:DecorationModel]()
    let thisSection = 0
    let normalRowId = 1000
    let detailedRowId = 2000
    let itemWidth = CGFloat(100)

    override var itemSize: CGSize {
        didSet {
            print("new val set: \(itemSize)")
        }
    }

    override func prepare() {
        super.prepare()
        print("prepare layout, item: \(itemSize)")
    }

    func registerDecorations() {
        //sectionHeadersPinToVisibleBounds = true
        let nib1 = UINib(nibName: "GridVerticalView", bundle: nil)
        register(nib1, forDecorationViewOfKind:DecorationKind.normal.rawValue)
        let nib2 = UINib(nibName: "GridVerticalDetailView", bundle: nil)
        register(nib2, forDecorationViewOfKind:DecorationKind.detailed.rawValue)
    }

    // collection view delegete, work around to update an item before it gets on screen
    // since the decoration view's apply method not always gets called
    func willDisplaySupplementaryView(_ view:UICollectionReusableView, elementKind:String, at indexPath:IndexPath) {
        print("will display: \(elementKind) at \(indexPath)")
        if let attr = layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath) {
            view.apply(attr)
        } else {
            print("alien element: \(elementKind)")
        }
    }

    // UICollectionViewLayoutAttributes:
    //        open var frame: CGRect
    //        open var center: CGPoint
    //        open var size: CGSize
    //        open var transform3D: CATransform3D

    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                                                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("attr1: \(elementKind)")

        guard let kind = DecorationKind(rawValue: elementKind) else { return nil }
        if let model = itemModels[indexPath.row] {
            if model.kind != kind {
                print("*** wrong model???")
            }
            return createAttrib(indexPath:indexPath, model:model)
        } else {
            let model = DecorationModel(x:150.0, title:"WRONG\nMODEL", color:UIColor.red)
            return createAttrib(indexPath:indexPath, model:model)
        }
    }

//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        print("attr2: \(indexPath)")
//        
//        let attrib = super.layoutAttributesForItem(at:indexPath)
//        if indexPath.row >= normalRowId {
//            print("[\(indexPath)] attrib: \(attrib)")
//        }
//        return attrib
//    }


     // return an array layout attributes instances for all the views in the given rect
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var resultAttributes = [UICollectionViewLayoutAttributes]()
        if let superAttrib = super.layoutAttributesForElements(in:rect) {
            resultAttributes.append(contentsOf: superAttrib)
        }

        for (row, model) in itemModels {
            if rect.minX <= model.x && rect.maxX > model.x {
                let indexPath = IndexPath(item:row, section: thisSection)
                let attr = createAttrib(indexPath:indexPath, model:model)
                resultAttributes.append(attr)
            }
        }

        return resultAttributes
    }

    private func createAttrib(indexPath:IndexPath, model:DecorationModel) -> UICollectionViewLayoutAttributes {
        let attr = DecorLayoutAttributes(forDecorationViewOfKind:model.kind.rawValue, with:indexPath)
        attr.frame = CGRect(x:model.x-itemWidth/2.0, y:0, width: itemWidth, height: itemSize.height)
        attr.model = model
        return attr
    }

    func test(indexPath:IndexPath) {
        if var mmm = itemModels[indexPath.item] {
            mmm.x = mmm.x + 50.0
            itemModels[indexPath.item] = mmm
        }
    }

    func getDecorationModel(at index:Int) -> DecorationModel? {
        return itemModels[index]
    }

    func getDecorationModels() -> [Int:DecorationModel] {
        return itemModels
    }

    func setDecorationModel(_ model:DecorationModel?, at index:Int) {
        var didChange = false
        let oldModel = itemModels[index]
        if let model = model {
            itemModels[index] = model
            didChange = true
        } else {
            if let _ = oldModel {
                itemModels.removeValue(forKey:index)
                didChange = true
            }
        }

        if didChange {
            let cx = UICollectionViewFlowLayoutInvalidationContext()
            let ip = IndexPath(item: index, section: 0)
            cx.invalidateDecorationElements(ofKind:DecorationKind.detailed.rawValue, at: [ip])
            invalidateLayout(with: cx)
        }
    }

    func setDecorationModels(_ models:[DecorationModel]) {
        let cx = UICollectionViewFlowLayoutInvalidationContext()
        // 1. remove old items
        for (i, model) in itemModels {
            let ip = IndexPath(item: i, section: 0)
            cx.invalidateDecorationElements(ofKind:model.kind.rawValue, at: [ip])
        }
        itemModels.removeAll()
        // 2. add new items
        var iNorm = normalRowId
        var iDetail = detailedRowId
        for m in models {
            switch m.kind! {
            case .normal:
            itemModels[iNorm] = m
            let ip = IndexPath(item:iNorm, section:0)
            cx.invalidateDecorationElements(ofKind:DecorationKind.normal.rawValue, at: [ip])
            iNorm += 1

            case .detailed:
            itemModels[iDetail] = m
            let ip = IndexPath(item:iDetail, section:0)
            cx.invalidateDecorationElements(ofKind:DecorationKind.detailed.rawValue, at: [ip])
            iDetail += 1
            }
        }

        invalidateLayout(with: cx)
    }
}

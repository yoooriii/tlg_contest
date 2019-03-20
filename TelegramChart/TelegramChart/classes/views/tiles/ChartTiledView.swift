//
//  ChartTiledView.swift
//  TelegramChart
//
//  Created by Leonid Lokhmatov on 3/20/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class PathTiledLayer: CATiledLayer {
    var fadeDuration: CFTimeInterval { return 0.0 }
}

class ChartTiledView: UIView {
    static let TILE_SIZE = CGFloat(256.0)
    override class var layerClass : AnyClass { return PathTiledLayer.self }
    lazy var tiledLayer:PathTiledLayer = { return self.layer as! PathTiledLayer }()

    var tileSize: CGSize = CGSize(width:TILE_SIZE, height:TILE_SIZE) {
        didSet {
            let tileSizeScaled = tileSize.applying(CGAffineTransform(scaleX:contentScaleFactor, y:contentScaleFactor))
            self.tiledLayer.tileSize = tileSizeScaled
        }
    }

    var numberOfZoomLevels: Int {
        get { return tiledLayer.levelsOfDetailBias }
        set { tiledLayer.levelsOfDetailBias = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.saveGState()

        let scale = ctx.ctm.a / tiledLayer.contentsScale
        let avgScale = sqrt(ctx.ctm.a*ctx.ctm.a+ctx.ctm.d*ctx.ctm.d) / tiledLayer.contentsScale
        let indexX = Int(rect.minX * scale / tileSize.width)
        let indexY = Int(rect.minY * scale / tileSize.height)
        print("[\(indexX):\(indexY)] ctm:a:\(ctx.ctm.a); b:\(ctx.ctm.b); c:\(ctx.ctm.c); d:\(ctx.ctm.d); sc:\(scale); avg.sc:\(avgScale)")

        let lineWidth = 2.0 / scale
        let fontSize = 16.0 / scale

        UIColor.yellow.set()
        NSString.localizedStringWithFormat(" %0.0f", log2f(Float(scale))).draw(
            at: CGPoint(x: rect.minX, y: rect.minY),
            withAttributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:fontSize)]
        )

        UIColor.red.set()
        ctx.setLineWidth(lineWidth)
        ctx.stroke(rect)

        //debug
        guard let slice = slice, slice.pathModels.count > 0 else { return }
        for pathModel in slice.pathModels {
            let strokeWidth = 2.0*pathModel.lineWidth/avgScale

            ctx.addPath(pathModel.path)
            ctx.setLineWidth(strokeWidth)
            ctx.setStrokeColor(pathModel.color.cgColor)
            ctx.strokePath()
        }

        ctx.restoreGState()
    }

    var slice:Slice? {
        didSet { updateSlice() }
    }

    private func updateSlice() {
//        if let slice = self.slice {
//        } else {
//        }
        tiledLayer.setNeedsDisplay()
    }

    private func internalInit() {
        let scaledTileSize = self.tileSize.applying(CGAffineTransform(scaleX: self.contentScaleFactor, y: self.contentScaleFactor))
        tiledLayer.tileSize = scaledTileSize
        tiledLayer.levelsOfDetail = 3
        tiledLayer.isGeometryFlipped = true
        tiledLayer.anchorPoint = CGPoint(x:0.0, y:0.5)
        numberOfZoomLevels = 3
    }
}

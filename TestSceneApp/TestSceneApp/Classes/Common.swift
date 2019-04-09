//
//  Common.swift
//  TestSceneApp
//
//  Created by Leonid Lokhmatov on 4/9/19.
//  Copyright © 2018 Luxoft. All rights reserved
//

import UIKit

class Common {
    static func createSinPath(bounds:CGRect, count:Int) -> CGPath {
        let path = CGMutablePath()
        var x = bounds.minX
        let dx = bounds.width / CGFloat(count)
        let amplitude = bounds.height
        let k = CGFloat(0.3)
        for i in 0...count {
            let y = sin(x * k) * amplitude
            let pt = CGPoint(x:x, y:y)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
            
            x += dx
        }
        
        x = bounds.minX
        for _ in 0...count {
            let y = sin(x * k) * amplitude
            let pt = CGPoint(x:x, y:y)
            
            let r = CGRect(origin: pt, size: CGSize.zero).insetBy(dx: -2, dy: -2)
            path.addEllipse(in: r)
            
            x += dx
        }
        
        return path
    }

}

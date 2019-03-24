//
//  HLayoutAttributes.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/24/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

struct DecorationModel {

    struct Value {
        var string:String
        var color:UIColor
    }

    var x:CGFloat!
    var values:[Value]!
    let kind:DecorationKind!
    var lineColor:UIColor?

    init(x:CGFloat!, values:[Value]!) {
        self.x = x
        self.kind = .detailed
        self.values = values
        self.lineColor = UIColor.lightGray
    }

    init(x:CGFloat!, title:String!, color:UIColor!) {
        self.x = x
        self.kind = .normal
        self.values = [Value(string: title, color: color)]
        self.lineColor = nil
    }
}

class DecorLayoutAttributes: UICollectionViewLayoutAttributes {
    var model:DecorationModel?
}

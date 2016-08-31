//
//  BlackToolBar.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/31/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

class BlackToolBar: UIToolbar {

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillRect(context, bounds)

        CGContextSetFillColorWithColor(context, UIColor(white: 0.1, alpha: 1.0).CGColor)
        CGContextFillRect(context, CGRect.init(x: 0.0, y: 0.0,
            width: bounds.size.width, height: 2.0))
        CGContextFillRect(context, CGRect.init(x: 0.0, y: bounds.size.height,
            width: bounds.size.width, height: bounds.size.height))
    }

}

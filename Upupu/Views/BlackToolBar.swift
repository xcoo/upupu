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

    private var topBorderEnabled = false
    private var bottomBorderEnabled = false

    init(topBorderEnabled: Bool = false, bottomBorderEnabled: Bool = false) {
        super.init(frame: CGRect.zero)
        self.topBorderEnabled = topBorderEnabled
        self.bottomBorderEnabled = bottomBorderEnabled
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(bounds)

        context?.setFillColor(UIColor(white: 0.2, alpha: 1.0).cgColor)

        if topBorderEnabled {
            context?.fill(CGRect.init(x: 0.0, y: 0.0, width: bounds.size.width, height: 1.0))
        }

        if bottomBorderEnabled {
            context?.fill(CGRect.init(x: 0.0, y: bounds.size.height - 2.0, width: bounds.size.width, height: 1.0))
        }
    }

}

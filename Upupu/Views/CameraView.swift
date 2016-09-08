//
//  CameraView.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 9/7/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

import Cartography

class CameraView: UIView {

    let previewView = UIView()
    let overlayView = UIView()

    let cameraButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Camera/Circle"),
                                     style: .Plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.whiteColor()
        return button
    }()

    let clipsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Camera/Album"),
                                     style: .Plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.whiteColor()
        return button
    }()

    let switchButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "Camera/Switch"), forState: .Normal)
        return button
    }()

    let torchButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "Camera/TorchOff"), forState: .Normal)
        return button
    }()

    let toolbar = BlackToolBar()

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.blackColor()

        addSubview(previewView)
        addSubview(overlayView)
        addSubview(torchButton)
        addSubview(switchButton)

        toolbar.items = [clipsButton,
                         UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil,
                            action: nil),
                         cameraButton,
                         UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil,
                            action: nil)]
        addSubview(toolbar)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        constrain(previewView) { view in
            view.top == view.superview!.top
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
            view.left == view.superview!.left
        }

        constrain(overlayView) { view in
            view.top == view.superview!.top
            view.bottom == view.superview!.bottom
            view.left == view.superview!.left
            view.right == view.superview!.right
        }

        constrain(torchButton) { button in
            button.width == 50
            button.height == 35
            button.top == button.superview!.top + 10
            button.left == button.superview!.left + 10
        }

        constrain(switchButton) { button in
            button.width == 50
            button.height == 35
            button.top == button.superview!.top + 10
            button.right == button.superview!.right - 10
        }

        constrain(toolbar) { toolbar in
            toolbar.bottom == toolbar.superview!.bottom
            toolbar.left == toolbar.superview!.left
            toolbar.right == toolbar.superview!.right
        }

        super.updateConstraints()
    }

}

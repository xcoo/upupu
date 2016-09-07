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

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.blackColor()

        self.addSubview(previewView)
        self.addSubview(overlayView)
        self.addSubview(torchButton)
        self.addSubview(switchButton)

        toolbar.items = [clipsButton,
                         UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil,
                            action: nil),
                         cameraButton,
                         UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil,
                            action: nil)]
        self.addSubview(toolbar)

        switchButton.hidden = !CameraHelper.frontCameraAvailable
        torchButton.hidden = !CameraHelper.torchAvailable ||
            !CameraHelper.sharedInstance.torchAvailable
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        constrain(previewView) { previewView in
            previewView.top == previewView.superview!.top
            previewView.right == previewView.superview!.right
            previewView.bottom == previewView.superview!.bottom
            previewView.left == previewView.superview!.left
        }

        constrain(overlayView) { overlayView in
            overlayView.top == overlayView.superview!.top
            overlayView.bottom == overlayView.superview!.bottom
            overlayView.left == overlayView.superview!.left
            overlayView.right == overlayView.superview!.right
        }

        constrain(torchButton) { button in
            button.width == 50
            button.height == 35
            if let superview = button.superview {
                button.top == superview.top + 10
                button.left == superview.left + 10
            }
        }

        constrain(switchButton) { button in
            button.width == 50
            button.height == 35
            if let superview = button.superview {
                button.top == superview.top + 10
                button.right == superview.right - 10
            }
        }

        constrain(toolbar) { toolbar in
            if let superview = toolbar.superview {
                toolbar.bottom == superview.bottom
                toolbar.left == superview.left
                toolbar.right == superview.right
            }
        }

        super.updateConstraints()
    }

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

}

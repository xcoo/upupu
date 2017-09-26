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
                                     style: .plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.white
        return button
    }()

    let clipsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Camera/Album"),
                                     style: .plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.white
        return button
    }()

    let switchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Camera/Switch"), for: [])
        return button
    }()

    let torchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Camera/TorchOff"), for: [])
        return button
    }()

    let toolbar: BlackToolBar = {
        let toolbar = BlackToolBar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.isHidden = true
        return label
    }()

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.black

        addSubview(previewView)
        addSubview(overlayView)
        addSubview(torchButton)
        addSubview(switchButton)

        toolbar.items = [clipsButton,
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         cameraButton,
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem()]
        addSubview(toolbar)

        addSubview(messageLabel)
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
            button.width == 35
            button.height == 35
            button.top == button.superview!.top + 10
            button.left == button.superview!.left + 10
        }

        constrain(switchButton) { button in
            button.width == 35
            button.height == 35
            button.top == button.superview!.top + 10
            button.right == button.superview!.right - 10
        }

        constrain(toolbar) { toolbar in
            toolbar.height == 80
            toolbar.bottom == toolbar.superview!.bottomMargin
            toolbar.left == toolbar.superview!.left
            toolbar.right == toolbar.superview!.right
        }

        constrain(messageLabel) { label in
            label.center == label.superview!.center
        }

        super.updateConstraints()
    }

}

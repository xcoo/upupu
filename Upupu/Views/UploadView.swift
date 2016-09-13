//
//  UploadView.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 9/7/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

import Cartography

class UploadView: UIView {

    private let topToolbar = BlackToolBar(bottomBorderEnabled: true)
    private let bottomToolbar = BlackToolBar(topBorderEnabled: true)

    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .RoundedRect
        textField.textAlignment = .Center
        textField.font = UIFont.systemFontOfSize(13)
        textField.placeholder = "Input name"
        return textField
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()

    let retakeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Camera/Back"),
                                     style: .Plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.whiteColor()
        return button
    }()

    let uploadButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Camera/Check"),
                                     style: .Plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.whiteColor()
        return button
    }()

    let settingsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Upload/Settings"),
                                     style: .Plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.whiteColor()
        return button
    }()

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.blackColor()

        addSubview(imageView)

        topToolbar.items = [UIBarButtonItem(customView: nameTextField)]
        addSubview(topToolbar)

        bottomToolbar.items = [retakeButton,
                               UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil,
                                action: nil),
                               uploadButton,
                               UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil,
                                action: nil),
                               settingsButton]
        addSubview(bottomToolbar)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        constrain(topToolbar) { toolbar in
            toolbar.top == toolbar.superview!.top + 22
            toolbar.left == toolbar.superview!.left
            toolbar.right == toolbar.superview!.right
        }

        constrain(bottomToolbar) { toolbar in
            toolbar.height == 80
            toolbar.bottom == toolbar.superview!.bottom
            toolbar.left == toolbar.superview!.left
            toolbar.right == toolbar.superview!.right
        }

        constrain(imageView, topToolbar, bottomToolbar) { imageView, topToolbar, bottomToolbar in
            imageView.top == topToolbar.bottom
            imageView.bottom == bottomToolbar.top
            imageView.left == imageView.superview!.left
            imageView.right == imageView.superview!.right
        }

        constrain(nameTextField, topToolbar) { textField, toolbar in
            textField.top == toolbar.top + 7
            textField.bottom == toolbar.bottom - 7
            textField.left == toolbar.left + 15
            textField.right == toolbar.right - 15
        }

        super.updateConstraints()
    }

}

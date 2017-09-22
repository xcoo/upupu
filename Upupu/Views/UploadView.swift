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

class UploadView: UIView, UIScrollViewDelegate {

    private let topToolbar = BlackToolBar(bottomBorderEnabled: true)
    private let bottomToolbar = BlackToolBar(topBorderEnabled: true)

    let nameTextField: FilenameTextField = {
        let textField = FilenameTextField(fileExtension: ".jpg")
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.placeholder = "Input name"
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.keyboardType = .asciiCapable
        return textField
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentMode = .scaleAspectFit
        scrollView.maximumZoomScale = 5
        scrollView.minimumZoomScale = 1
        return scrollView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let retakeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Camera/Back"),
                                     style: .plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.white
        return button
    }()

    let uploadButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Camera/Check"),
                                     style: .plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.white
        return button
    }()

    let settingsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Upload/Settings"),
                                     style: .plain,
                                     target: nil,
                                     action: nil)
        button.tintColor = UIColor.white
        return button
    }()

    private var imageViewSizeConstraint = ConstraintGroup()
    private var imageViewOriginConstraint = ConstraintGroup()

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.black

        scrollView.addSubview(imageView)
        addSubview(scrollView)
        scrollView.delegate = self

        topToolbar.items = [UIBarButtonItem(customView: nameTextField)]
        addSubview(topToolbar)

        bottomToolbar.items = [retakeButton,
                               UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                               uploadButton,
                               UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
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
            toolbar.top == toolbar.superview!.topMargin
            toolbar.left == toolbar.superview!.left
            toolbar.right == toolbar.superview!.right
        }

        constrain(bottomToolbar) { toolbar in
            toolbar.height == 80
            toolbar.bottom == toolbar.superview!.bottomMargin
            toolbar.left == toolbar.superview!.left
            toolbar.right == toolbar.superview!.right
        }

        constrain(imageView, replace: imageViewOriginConstraint) { imageView in
            imageView.center == imageView.superview!.center
        }

        constrain(scrollView, topToolbar, bottomToolbar) { scrollView, topToolbar, bottomToolbar in
            scrollView.top == topToolbar.bottom
            scrollView.bottom == bottomToolbar.top
            scrollView.left == scrollView.superview!.left
            scrollView.right == scrollView.superview!.right
        }

        constrain(nameTextField, topToolbar) { textField, toolbar in
            textField.top == toolbar.top + 7
            textField.bottom == toolbar.bottom - 7
            textField.left == toolbar.left + 15
            textField.right == toolbar.right - 15
        }

        super.updateConstraints()
    }

    func updateImageViewSize() {
        if let image = imageView.image {
            let imageRatio = image.size.width / image.size.height
            let scrollViewRatio = scrollView.bounds.width / scrollView.bounds.height
            if imageRatio > scrollViewRatio {
                constrain(imageView, replace: imageViewSizeConstraint) { imageView in
                    imageView.width == scrollView.bounds.width
                    imageView.height == scrollView.bounds.width / imageRatio
                }
            } else {
                constrain(imageView, replace: imageViewSizeConstraint) { imageView in
                    imageView.width == scrollView.bounds.height * imageRatio
                    imageView.height == scrollView.bounds.height
                }
            }
        }
    }

    func reset() {
        nameTextField.text = ""
        scrollView.zoomScale = 1
        constrain(imageView, replace: imageViewOriginConstraint) { imageView in
            imageView.center == imageView.superview!.center
        }
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentSize.width < scrollView.bounds.width ?
            (scrollView.bounds.width - scrollView.contentSize.width) / 2 : 0
        let offsetY = scrollView.contentSize.height < scrollView.bounds.height ?
            (scrollView.bounds.height - scrollView.contentSize.height) / 2 : 0
        constrain(imageView, replace: imageViewOriginConstraint) { imageView in
            imageView.left == imageView.superview!.left + offsetX
            imageView.top == imageView.superview!.top + offsetY
        }
    }

}

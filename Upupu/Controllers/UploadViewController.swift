//
//  UploadViewController.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/29/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

import MBProgressHUD

protocol UploadViewControllerDelegate: class {

    func uploadViewControllerDidReturn(uploadViewController: UploadViewController)
    func uploadViewControllerDidFinished(uploadViewController: UploadViewController)
    func uploadViewControllerDidSetup(uploadViewController: UploadViewController)

}

class UploadViewController: UIViewController, MBProgressHUDDelegate, UITextFieldDelegate {

    weak var delegate: UploadViewControllerDelegate?

    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var retakeButton: UIBarItem!
    @IBOutlet private weak var uploadButton: UIBarItem!
    @IBOutlet private weak var settingsButton: UIBarItem!

    var image: UIImage?
    var shouldSavePhotoAlbum = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        imageView.image = image

        nameField.enabled = image != nil
        uploadButton.enabled = image != nil

        if let text = nameField.text {
            if text.isEmpty {
                nameField.text = makeFilename()
            }
        } else {
            nameField.text = makeFilename()
        }

        super.viewWillAppear(animated)
    }

    override func shouldAutorotate() -> Bool {
        return UIDevice.currentDevice().orientation == .Portrait
    }

    private func makeFilename() -> String {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.stringFromDate(date)
    }

    // MARK: - Action

    @IBAction private func retakeButtonTapped(sender: UIBarItem) {
        nameField.text = ""
        delegate?.uploadViewControllerDidReturn(self)
    }

    @IBAction private func uploadButtonTapped(sender: UIBarItem) {
        if !Settings.webDAVEnabled && !Settings.dropboxEnabled {
            UIAlertController.showSimpleAlertIn(navigationController, title: "Error",
                                            message: "Setup server configuration before uploading")
            return
        }

        if Settings.webDAVEnabled &&
            (Settings.webDAVURL == nil || Settings.webDAVURL!.isEmpty) {
            UIAlertController.showSimpleAlertIn(navigationController, title: "Error",
                                                message: "Invalid WebDAV server URL")
            return
        }

        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {[weak self] in
            self?.launchUpload(hud)
        }
    }

    @IBAction private func settingsButtonTapped(sender: UIBarItem) {
        delegate?.uploadViewControllerDidSetup(self)
    }

    // MARK: - Picture processing

    private func scaleImage(image: UIImage?) -> UIImage? {
        switch Settings.photoResolution {
        case .Original:
            return image
        case .Medium:
            return image?.scaledImage(CGSize.init(width: 1600, height: 1200))
        case .Small:
            return image?.scaledImage(CGSize.init(width: 800, height: 600))
        }
    }

    private func imageData(image: UIImage) -> NSData? {
        let quality: Float
        switch Settings.photoQuality {
        case .High:
            quality = 1.0
        case .Medium:
            quality = 0.6
        case .Low:
            quality = 0.2
        }
        return UIImageJPEGRepresentation(image, CGFloat(quality))
    }

    private func showFailed(hud: MBProgressHUD?) {
        if let hud = hud {
            hud.customView = UIImageView(image: UIImage(named: "failure_icon"))
            hud.mode = .CustomView
            hud.label.text = "Failed"
            hud.detailsLabel.text = ""
        }
    }

    private func showSucceeded(hud: MBProgressHUD?) {
        if let hud = hud {
            hud.customView = UIImageView(image: UIImage(named: "success_icon"))
            hud.mode = .CustomView
            hud.label.text = "Succeeded"
            hud.detailsLabel.text = ""
        }
    }

    private func execUpload<T: Uploadable>(uploader: T, filename: String?, imageData: NSData,
                            hud: MBProgressHUD?) {
        uploader.upload(filename, imageData: imageData) { (error) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {[weak self] in
                    self?.showSucceeded(hud)
                }

                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(time, dispatch_get_main_queue()) {[weak self] in
                    hud?.hideAnimated(true)
                    self?.nameField.text = ""
                    if let self_ = self {
                        self_.delegate?.uploadViewControllerDidFinished(self_)
                    }

                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {[weak self] in
                    self?.showFailed(hud)
                }

                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(time, dispatch_get_main_queue()) {
                    hud?.hideAnimated(true)
                }
            }
        }
    }

    private func launchUpload(hud: MBProgressHUD?) {
        guard let image = scaleImage(self.image) else {
            return
        }

        // Save to album
        if shouldSavePhotoAlbum && Settings.shouldSavePhoto {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }

        // Upload to ...
        if let imageData = imageData(image) {
            let filename = nameField.text

            // WebDAV
            if Settings.webDAVEnabled {
                dispatch_sync(dispatch_get_main_queue(), {
                    hud?.detailsLabel.text = "WebDAV"
                    })
                execUpload(WebDAVUploader(), filename: filename, imageData: imageData, hud: hud)
            }

            // Dropbox
            if Settings.dropboxEnabled {
                dispatch_sync(dispatch_get_main_queue(), {
                    hud?.detailsLabel.text = "Dropbox"
                    })
                execUpload(DropboxUploader(), filename: filename, imageData: imageData, hud: hud)
            }
        }
    }

    // MARK: - TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

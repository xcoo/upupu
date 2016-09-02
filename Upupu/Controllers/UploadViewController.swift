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

    private var hud: MBProgressHUD?

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

        hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {[weak self] in
            self?.launchUpload()
        }
    }

    @IBAction private func settingsButtonTapped(sender: UIBarItem) {
        delegate?.uploadViewControllerDidSetup(self)
    }

    // MARK: - Picture processing

    private func showFailed() {
        if let hud = hud {
            hud.customView = UIImageView(image: UIImage(named: "failure_icon"))
            hud.mode = .CustomView
            hud.label.text = "Failed"
            hud.detailsLabel.text = ""
        }
    }

    private func showSucceeded() {
        if let hud = hud {
            hud.customView = UIImageView(image: UIImage(named: "success_icon"))
            hud.mode = .CustomView
            hud.label.text = "Succeeded"
            hud.detailsLabel.text = ""
        }
    }

    func launchUpload() {
        var image: UIImage?
        switch Settings.photoResolution {
        case 0:
            image = self.image
        case 1:
            image = self.image?.scaledImage(CGSize.init(width: 1600, height: 1200))
        case 2:
            image = self.image?.scaledImage(CGSize.init(width: 800, height: 600))
        default: break
        }

        var quality = 1.0
        switch Settings.photoQuality {
        case 0: quality = 1.0 // High
        case 1: quality = 0.6 // Medium
        case 2: quality = 0.2 // Low
        default: break
        }

        if let image = image {
            if shouldSavePhotoAlbum && Settings.shouldSavePhoto {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }

            if let imageData = UIImageJPEGRepresentation(image, CGFloat(quality)),
                filename = nameField.text {
                // WebDAV
                if Settings.webDAVEnabled {
                    dispatch_sync(dispatch_get_main_queue(), {[weak self] in
                        self?.hud?.detailsLabel.text = "WebDAV"
                        })

                    let uploader = WebDAVUploader()
                    uploader.upload(filename, imageData: imageData, completion: { (error) in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue(), {[weak self] in
                                self?.showSucceeded()
                                })
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))),
                            dispatch_get_main_queue()) {[weak self] in
                                if let self_ = self {
                                    self_.hud?.hideAnimated(true)
                                    self_.nameField.text = ""
                                    self_.delegate?.uploadViewControllerDidFinished(self_)
                                }
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {[weak self] in
                                self?.showFailed()
                                })
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))),
                            dispatch_get_main_queue()) {[weak self] in
                                self?.hud?.hideAnimated(true)
                            }
                        }
                    })
                }

                // Dropbox
                if Settings.dropboxEnabled {
                    dispatch_sync(dispatch_get_main_queue(), {[weak self] in
                        self?.hud?.detailsLabel.text = "Dropbox"
                        })

                    let uploader = DropboxUploader.sharedInstance
                    uploader.upload(filename, imageData: imageData, completion: {[weak self] (error) in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue(), {[weak self] in
                                self?.showSucceeded()
                                })
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))),
                            dispatch_get_main_queue()) {[weak self] in
                                if let self_ = self {
                                    self_.hud?.hideAnimated(true)
                                    self_.nameField.text = ""
                                    self_.delegate?.uploadViewControllerDidFinished(self_)
                                }
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {[weak self] in
                                self?.showFailed()
                                })
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))),
                            dispatch_get_main_queue()) {[weak self] in
                                self?.hud?.hideAnimated(true)
                            }

                        }
                    })
                }
            }
        }
    }

    // MARK: - TextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

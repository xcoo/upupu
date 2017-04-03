//
//  UploadViewController.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/29/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

import Alamofire
import MBProgressHUD

protocol UploadViewControllerDelegate: class {

    func uploadViewControllerDidReturn(_ uploadViewController: UploadViewController)
    func uploadViewControllerDidFinished(_ uploadViewController: UploadViewController)
    func uploadViewControllerDidSetup(_ uploadViewController: UploadViewController)

}

class UploadViewController: UIViewController, MBProgressHUDDelegate, UITextFieldDelegate {

    weak var delegate: UploadViewControllerDelegate?

    private var uploadView: UploadView!

    var image: UIImage?
    var shouldSavePhotoAlbum = true

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        uploadView = UploadView()
        view = uploadView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        uploadView.retakeButton.action = #selector(retakeButtonTapped)
        uploadView.uploadButton.action = #selector(uploadButtonTapped)
        uploadView.settingsButton.action = #selector(settingsButtonTapped)

        uploadView.nameTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        uploadView.imageView.image = image

        uploadView.nameTextField.isEnabled = image != nil
        uploadView.uploadButton.isEnabled = image != nil

        if let text = uploadView.nameTextField.text {
            if text.isEmpty {
                uploadView.nameTextField.fileStem = makeFilename()
            }
        } else {
            uploadView.nameTextField.fileStem = makeFilename()
        }

        super.viewWillAppear(animated)
    }

    override var shouldAutorotate: Bool {
        return UIDevice.current.orientation == .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    private func makeFilename() -> String {
        return DateHelper.dateTimeString()
    }

    // MARK: - Action

    @objc private func retakeButtonTapped(_ sender: UIBarItem) {
        uploadView.nameTextField.text = ""
        delegate?.uploadViewControllerDidReturn(self)
    }

    @objc private func uploadButtonTapped(_ sender: UIBarItem) {
        guard Settings.webDAVEnabled || Settings.dropboxEnabled else {
            UIAlertController.showSimpleErrorAlertIn(navigationController,
                                                     error: UPError.settingsNotSetUp)
            return
        }

        // Checking network connection
        guard let net = NetworkReachabilityManager() else {
            UIAlertController.showSimpleErrorAlertIn(navigationController,
                                                     error: .networkUnreachable)
            return
        }
        net.startListening()
        let isReachable = net.isReachable
        net.stopListening()
        guard isReachable else {
            UIAlertController.showSimpleErrorAlertIn(navigationController,
                                                     error: .networkUnreachable)
            return
        }

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global(qos: .background).async {[weak self] in
            self?.launchUpload(hud)
        }
    }

    @objc private func settingsButtonTapped(_ sender: UIBarItem) {
        delegate?.uploadViewControllerDidSetup(self)
    }

    // MARK: - Picture processing

    private func scaleImage(_ image: UIImage?) -> UIImage? {
        switch Settings.photoResolution {
        case .original:
            return image
        case .medium:
            return image?.scaledImage(CGSize.init(width: 1600, height: 1200))
        case .small:
            return image?.scaledImage(CGSize.init(width: 800, height: 600))
        }
    }

    private func imageData(_ image: UIImage) -> Data? {
        let quality: Float
        switch Settings.photoQuality {
        case .high:
            quality = 1.0
        case .medium:
            quality = 0.6
        case .low:
            quality = 0.2
        }
        return UIImageJPEGRepresentation(image, CGFloat(quality))
    }

    private func showFailed(_ hud: MBProgressHUD?, message: String? = nil) {
        if let hud = hud {
            hud.customView = UIImageView(image: UIImage(named: "Upload/Failure"))
            hud.mode = .customView
            hud.label.text = "Failed"
            hud.detailsLabel.text = message
        }
    }

    private func showSucceeded(_ hud: MBProgressHUD?) {
        if let hud = hud {
            hud.customView = UIImageView(image: UIImage(named: "Upload/Success"))
            hud.mode = .customView
            hud.label.text = "Succeeded"
            hud.detailsLabel.text = ""
        }
    }

    private func execUpload<T: Uploadable>(_ uploader: T, filename: String, imageData: Data,
                                           hud: MBProgressHUD?) {
        uploader.upload(filename, data: imageData) { (error) in
            guard error == nil else {
                DispatchQueue.main.async {[weak self] in
                    self?.showFailed(hud, message: error?.description)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    hud?.hide(animated: true)
                }

                return
            }

            DispatchQueue.main.async {[weak self] in
                self?.showSucceeded(hud)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
                hud?.hide(animated: true)
                self?.uploadView.nameTextField.text = ""
                if let self_ = self {
                    self_.delegate?.uploadViewControllerDidFinished(self_)
                }
            }
        }
    }

    private func launchUpload(_ hud: MBProgressHUD?) {
        guard let image = scaleImage(self.image) else {
            return
        }

        // Save to album
        if shouldSavePhotoAlbum && Settings.shouldSavePhoto {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }

        // Upload to ...
        if let imageData = imageData(image) {
            let fileStem = uploadView.nameTextField.fileStem
            let filename: String
            if fileStem == nil || fileStem!.isEmpty {
                filename = "\(Uploader.fileStem()).jpg"
            } else {
                filename = "\(fileStem!).jpg"
            }

            // WebDAV
            if Settings.webDAVEnabled {
                DispatchQueue.main.sync(execute: {
                    hud?.detailsLabel.text = "WebDAV"
                    })
                execUpload(WebDAVUploader(), filename: filename, imageData: imageData, hud: hud)
            }

            // Dropbox
            if Settings.dropboxEnabled {
                DispatchQueue.main.sync(execute: {
                    hud?.detailsLabel.text = "Dropbox"
                    })
                execUpload(DropboxUploader(), filename: filename, imageData: imageData, hud: hud)
            }
        }
    }

    // MARK: - TextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let filenameTextField = textField as? FilenameTextField {
            filenameTextField.extentionHidden = true
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let filenameTextField = textField as? FilenameTextField {
            filenameTextField.extentionHidden = false
        }
    }

}

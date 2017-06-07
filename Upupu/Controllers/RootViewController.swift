//
//  RootViewController.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/29/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

import InAppSettingsKit
import SwiftyDropbox

class RootViewController: UINavigationController, CameraViewControllerDelegate,
UploadViewControllerDelegate, IASKSettingsDelegate {

    private var cameraViewController: CameraViewController!
    private var uploadViewController: UploadViewController!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        initialize()
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    private func initialize() {
        cameraViewController = CameraViewController()
        cameraViewController.delegate = self

        uploadViewController = UploadViewController()
        uploadViewController.delegate = self

        navigationBar.barStyle = UIBarStyle.blackOpaque
        navigationBar.isHidden = true

        pushViewController(cameraViewController, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var shouldAutorotate: Bool {
        return UIDevice.current.orientation == .portrait
    }

    // MARK: - CameraViewControllerDelegate

    func cameraViewController(_ cameraViewController: CameraViewController,
                              didFinishedWithImage image: UIImage?) {
        uploadViewController.image = image
        uploadViewController.shouldSavePhotoAlbum = !cameraViewController.isSourcePhotoLibrary

        pushViewController(uploadViewController, animated: true)
    }

    // MARK: - UploadViewControllerDelegate

    func uploadViewControllerDidReturn(_ uploadViewController: UploadViewController) {
        cameraViewController.isSourcePhotoLibrary = false

        popViewController(animated: true)
    }

    func uploadViewControllerDidFinished(_ uploadViewController: UploadViewController) {
        popViewController(animated: true)
    }

    func uploadViewControllerDidSetup(_ uploadViewController: UploadViewController) {
        let settingsViewController = IASKAppSettingsViewController()
        settingsViewController.delegate = self
        settingsViewController.showCreditsFooter = false
        settingsViewController.neverShowPrivacySettings = true

        if Constants.Dropbox.kDBAppKey.isEmpty ||
            Constants.Dropbox.kDBAppKey == "YOUR_DROPBOX_APP_KEY" {
            let hiddenKeys = ["dropbox_group_pref",
                              "dropbox_enabled_pref",
                              "dropbox_link_pref",
                              "dropbox_link_pref",
                              "dropbox_account_pref",
                              "dropbox_location_pref"]
            settingsViewController.hiddenKeys = Set(hiddenKeys)
        }

        let navigationContoller = UINavigationController(rootViewController: settingsViewController)
        navigationContoller.modalTransitionStyle = .coverVertical

        present(navigationContoller, animated: true, completion: nil)
    }

    // MARK: - IASKSettingsDelegate

    func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController) {
        sender.dismiss(animated: true, completion: nil)
    }

    func settingsViewController(_ sender: IASKAppSettingsViewController, buttonTappedFor specifier: IASKSpecifier) {
        if specifier.key() == "dropbox_link_pref" {
            if DropboxClientsManager.authorizedClient == nil {
                sender.dismiss(animated: true) {[weak self] in
                    DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                                  controller: self,
                                                                  openURL: { UIApplication.shared.openURL($0) })}
            } else {
                DropboxClientsManager.unlinkClients()
                Settings.dropboxEnabled = false
                Settings.dropboxLinkButtonTitle = "Connect to Dropbox"
                Settings.dropboxAccount = ""
            }
        }
    }

}

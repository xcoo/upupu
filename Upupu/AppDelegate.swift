//
//  AppDelegate.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/29/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupDefaults()
        DropboxClientsManager.setupWithAppKey(Constants.Dropbox.kDBAppKey)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur
        // for certain types of temporary interruptions (such as an incoming phone call or SMS
        // message) or when the user quits the application and it begins the transition to the
        // background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame
        // rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store
        // enough application state information to restore your application to its current state in
        // case it is terminated later.
        // If your application supports background execution, this method is called instead of
        // applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can
        // undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was
        // inactive. If the application was previously in the background, optionally refresh the
        // user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also
        // applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
                enableDropboxSettings()
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
        }

        return false
    }

    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
                enableDropboxSettings()
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
        }

        return false
    }

    // MARK: - Settings management

    private func setupDefaults() {
        let plistPath = Bundle.main.bundlePath
            .stringByAppendingPathComponent("Settings.bundle")
            .stringByAppendingPathComponent("Root.inApp.plist")

        if let settingsDictionary = NSDictionary(contentsOfFile: plistPath),
            let preferencesArray = settingsDictionary["PreferenceSpecifiers"] as? NSArray {
            let defaults = UserDefaults.standard
            for item in preferencesArray {
                if let v = item as? NSDictionary, let key = v["Key"] as? String {
                    if let defaultValue = v["DefaultValue"], defaults.object(forKey: key) == nil {
                        defaults.set(defaultValue, forKey: key)
                        print("Set default value \(defaultValue) for \(key)")
                    }
                }
            }
            defaults.synchronize()
        }
    }

    private func enableDropboxSettings() {
        Settings.dropboxEnabled = true
        Settings.dropboxLinkButtonTitle = "Unlink Dropbox"
        if let client = DropboxClientsManager.authorizedClient {
            client.users.getCurrentAccount().response { (response, _) in
                if let account = response {
                    Settings.dropboxAccount = account.name.displayName
                }
            }
        }
    }

}

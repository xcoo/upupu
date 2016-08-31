//
//  Settings.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/31/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

final class Settings {

    static var webDAVEnabled: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("webdav_enabled_pref")
    }

    static var webDAVURL: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey("webdav_url_pref")
    }

    static var webDAVUser: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey("webdav_user_pref")
    }

    static var webDAVPassword: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey("webdav_pass_pref")
    }

    static var dropboxEnabled: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("dropbox_enabled_pref")
        }

        set(enabled) {
            NSUserDefaults.standardUserDefaults().setBool(enabled, forKey: "dropbox_enabled_pref")
        }
    }

    static var dropboxAccount: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("dropbox_account_pref")
        }

        set(account) {
            NSUserDefaults.standardUserDefaults().setObject(account, forKey: "dropbox_account_pref")
        }
    }

    static var dropboxLocation: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey("dropbox_location_pref")
    }

    static var photoQuality: Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("photo_quality_pref")
    }

    static var photoResolution: Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("photo_resolution_pref")
    }

    static var shouldSavePhoto: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("photo_save_album_pref")
    }

}

//
//  Settings.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/31/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

enum PhotoQuality {
    case high
    case medium
    case low
}

enum PhotoResolution {
    case original
    case medium
    case small
}

final class Settings {

    static var webDAVEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "webdav_enabled_pref")
    }

    static var webDAVURL: String? {
        return UserDefaults.standard.string(forKey: "webdav_url_pref")
    }

    static var webDAVUser: String? {
        return UserDefaults.standard.string(forKey: "webdav_user_pref")
    }

    static var webDAVPassword: String? {
        return UserDefaults.standard.string(forKey: "webdav_pass_pref")
    }

    static var dropboxEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "dropbox_enabled_pref")
        }

        set(enabled) {
            UserDefaults.standard.set(enabled, forKey: "dropbox_enabled_pref")
        }
    }

    static var dropboxAccount: String? {
        get {
            return UserDefaults.standard.string(forKey: "dropbox_account_pref")
        }

        set(account) {
            UserDefaults.standard.set(account, forKey: "dropbox_account_pref")
        }
    }

    static var dropboxLinkButtonTitle: String? {
        get {
            return UserDefaults.standard.string(forKey: "dropbox_link_pref")
        }

        set(title) {
            UserDefaults.standard.set(title, forKey: "dropbox_link_pref")
        }
    }

    static var dropboxLocation: String? {
        return UserDefaults.standard.string(forKey: "dropbox_location_pref")
    }

    static var photoQuality: PhotoQuality {
        switch UserDefaults.standard.integer(forKey: "photo_quality_pref") {
        case 0:
            return .high
        case 1:
            return .medium
        case 2:
            return .low
        default:
            return .high
        }
    }

    static var photoResolution: PhotoResolution {
        switch UserDefaults.standard.integer(forKey: "photo_resolution_pref") {
        case 0:
            return .original
        case 1:
            return .medium
        case 2:
            return .small
        default:
            return .original
        }
    }

    static var shouldSavePhoto: Bool {
        return UserDefaults.standard.bool(forKey: "photo_save_album_pref")
    }

}

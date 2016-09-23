//
//  WebDAVUploader.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/30/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

class WebDAVUploader: Uploader, Uploadable {

    func upload(filename: String, data: NSData, completion: ((error: UPError?) -> Void)?) {

        let baseURL: String

        // Validate server path
        guard let settingsURL = Settings.webDAVURL else {
            completion?(error: .WebDAVNoURL)
            return
        }
        if settingsURL[settingsURL.endIndex.advancedBy(-1)] != "/" {
            baseURL = settingsURL + "/"
        } else {
            baseURL = settingsURL
        }

        // Validate http scheme
        if !(baseURL.hasPrefix("http://") || baseURL.hasPrefix("https://")) {
            completion?(error: .WebDAVInvalidScheme)
            return
        }

        // Directory name
        let now = NSDate()
        let dirName = directoryName(now)
        let dirURL = "\(baseURL)\(dirName)/"

        // File path
        let putURL = "\(baseURL)\(dirName)/\(filename)"

        let data = NSData(data: data)

        let request = WebDAVClient.createDirectory(dirURL)
        if let user = Settings.webDAVUser, password = Settings.webDAVPassword {
            request.authenticate(user: user, password: password)
        }
        request.response { (response, error) in
            print(response)

            guard error == nil || response?.statusCode == 405 else {
                print(error)
                completion?(error: .WebDAVCreateDirectoryFailure)
                return
            }

            let request = WebDAVClient.upload(putURL, data: data)
            if let user = Settings.webDAVUser, password = Settings.webDAVPassword {
                request.authenticate(user: user, password: password)
            }
            request.response { (response, error) in
                print(response)
                if let error = error {
                    print(error)
                    completion?(error: .WebDAVUploadFailure)
                } else {
                    completion?(error: nil)
                }
            }
        }
    }

}

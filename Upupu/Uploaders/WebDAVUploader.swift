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

    func upload(fileStem: String!, imageData: NSData, completion: ((error: Any?) -> Void)?) {

        let baseURL: String

        // Validate server path
        guard let settingsURL = Settings.webDAVURL else {
            completion?(error: "Invalid WebDAV URL")
            return
        }
        if settingsURL[settingsURL.endIndex.advancedBy(-1)] != "/" {
            baseURL = settingsURL + "/"
        } else {
            baseURL = settingsURL
        }

        // Validate http scheme
        if !(baseURL.hasPrefix("http://") || baseURL.hasPrefix("https://")) {
            completion?(error: "Invalid HTTP scheme")
            return
        }

        // Directory name
        let now = NSDate()
        let dirName = directoryName(now)
        let dirURL = "\(baseURL)\(dirName)/"

        // Filename
        let filename_: String
        if fileStem == nil || fileStem.isEmpty {
            filename_ = filename(now)
        } else {
            filename_ = "\(fileStem).jpg"
        }
        let putURL = "\(baseURL)\(dirName)/\(filename_)"

        let data = NSData(data: imageData)

        let request = WebDAVClient.createDirectory(dirURL)
        if let user = Settings.webDAVUser, password = Settings.webDAVPassword {
            request.authenticate(user: user, password: password)
        }
        request.response { (response, error) in
            print(response)
            if let error = error {
                print(error)
                completion?(error: error)
            } else {
                let request = WebDAVClient.upload(putURL, data: data)
                if let user = Settings.webDAVUser, password = Settings.webDAVPassword {
                    request.authenticate(user: user, password: password)
                }
                request.response { (response, error) in
                    print(response)
                    if let error = error {
                        print(error)
                        completion?(error: error)
                    } else {
                        completion?(error: nil)
                    }
                }
            }
        }
    }

}

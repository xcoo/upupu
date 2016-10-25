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

    private func validatedURL(url: String!) throws -> String {
        if url == nil || url.isEmpty {
            throw UPError.webDAVNoURL
        }

        if !(url.hasPrefix("http://") || url.hasPrefix("https://")) {
            throw UPError.webDAVInvalidScheme
        }

        return url
    }

    func upload(_ filename: String, data: Data, completion: ((_ error: UPError?) -> Void)?) {
        let baseURL: String
        let settingsURL: String

        do {
            settingsURL = try validatedURL(url: Settings.webDAVURL)
        } catch {
            completion?(error as? UPError)
            return
        }

        if settingsURL[settingsURL.characters.index(settingsURL.endIndex, offsetBy: -1)] != "/" {
            baseURL = settingsURL + "/"
        } else {
            baseURL = settingsURL
        }

        // Directory name
        let now = Date()
        let dirName = directoryName(now)
        let dirURL = "\(baseURL)\(dirName)/"

        // File path
        let putURL = "\(baseURL)\(dirName)/\(filename)"

        let data = NSData(data: data) as Data

        let request = WebDAVClient.createDirectory(dirURL)
        if let user = Settings.webDAVUser, let password = Settings.webDAVPassword {
            _ = request.authenticate(user: user, password: password)
        }
        _ = request.response { (response, error) in
            print(response)

            guard error == nil || response?.statusCode == 405 else {
                print(error)
                completion?(.webDAVCreateDirectoryFailure)
                return
            }

            let request = WebDAVClient.upload(putURL, data: data)
            if let user = Settings.webDAVUser, let password = Settings.webDAVPassword {
                _ = request.authenticate(user: user, password: password)
            }
            _ = request.response { (response, error) in
                print(response)
                if let error = error {
                    print(error)
                    completion?(.webDAVUploadFailure)
                } else {
                    completion?(nil)
                }
            }
        }
    }

}

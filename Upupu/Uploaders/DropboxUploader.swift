//
//  DropboxUploader.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/30/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation
import SwiftyDropbox

class DropboxUploader: Uploader, Uploadable {

    func upload(fileStem: String!, imageData: NSData, completion: ((error: Any?) -> Void)?) {
        guard let client = Dropbox.authorizedClient else {
            completion?(error: "Dropbox account is unauthorized")
            return
        }

        guard let dropboxLocation = Settings.dropboxLocation else {
            completion?(error: "Invalid Dropbox location")
            return
        }

        let now = NSDate()
        let dirPath = "\(dropboxLocation)/\(directoryName(now))"

        let filename_: String
        if fileStem == nil || fileStem.isEmpty {
            filename_ = filename(now)
        } else {
            filename_ = "\(fileStem).jpg"
        }

        let savePath = dirPath.stringByAppendingPathComponent(filename_)

        client.files.upload(path: savePath, input: imageData).response { (response, error) in
            if let metadata = response {
                print("Uploaded file name: \(metadata.name)")
                print("Uploaded file revision: \(metadata.rev)")
                completion?(error: nil)
            } else {
                completion?(error: error!)
            }
        }
    }

}

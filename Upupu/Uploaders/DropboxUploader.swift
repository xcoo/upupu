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

class DropboxUploader: Uploadable {

    static var sharedInstance = DropboxUploader()

    func upload(filename: String!, imageData: NSData!, completion: ((error: Any?) -> Void)?) {
        guard let client = Dropbox.authorizedClient else {
            completion?(error: "Dropbox account is unauthorized")
            return
        }

        guard let dropboxLocation = Settings.dropboxLocation else {
            completion?(error: "Invalid Dropbox location")
            return
        }

        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dbSaveDirectory = "\(dropboxLocation)/\(formatter.stringFromDate(now))"

        let dbFilename: String
        if filename == nil || filename.isEmpty {
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            dbFilename = "\(formatter.stringFromDate(now)).jpg"
        } else {
            dbFilename = "\(filename).jpg"
        }

        let savePath = dbSaveDirectory.stringByAppendingPathComponent(dbFilename)

        // Upload to Dropbox
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

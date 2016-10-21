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

    func upload(_ filename: String, data: Data, completion: ((_ error: UPError?) -> Void)?) {
        guard let client = DropboxClientsManager.authorizedClient else {
            completion?(.dropboxUnauthorized)
            return
        }

        guard let dropboxLocation = Settings.dropboxLocation else {
            completion?(.dropboxInvalidLocation)
            return
        }

        let now = Date()
        let dirPath = "\(dropboxLocation)/\(directoryName(now))"

        let savePath = dirPath.stringByAppendingPathComponent(filename)

        client.files.upload(path: savePath, input: data).response { (response, error) in
            if let metadata = response {
                print("Uploaded file name: \(metadata.name)")
                print("Uploaded file revision: \(metadata.rev)")
                completion?(nil)
            } else {
                completion?(.dropboxUploadFailure)
            }
        }
    }

}

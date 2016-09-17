//
//  UPError.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 9/17/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

enum UPError {

    case WebDAVNoURL
    case WebDAVInvalidScheme
    case WebDAVCreateDirectoryFailure
    case WebDAVUploadFailure

    case DropboxUnauthorized
    case DropboxInvalidLocation
    case DropboxUploadFailure

    var description: String? {
        switch self {
        case .WebDAVNoURL:
            return "WebDAV URL is not set up"
        case .WebDAVInvalidScheme:
            return "WebDAV HTTP scheme is invalid"
        case .WebDAVCreateDirectoryFailure:
            return "Failed to create a directory on WebDAV"
        case .WebDAVUploadFailure:
            return "Failed to upload the file to WebDAV"
        case .DropboxUnauthorized:
            return "Dropbox account is unauthorized"
        case .DropboxInvalidLocation:
            return "Invalid Dropbox location"
        case .DropboxUploadFailure:
            return "Failed to upload the file to Dropbox"
        }
    }

}

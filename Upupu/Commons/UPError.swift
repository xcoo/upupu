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

    case webDAVNoURL
    case webDAVInvalidScheme
    case webDAVCreateDirectoryFailure
    case webDAVUploadFailure

    case dropboxUnauthorized
    case dropboxInvalidLocation
    case dropboxUploadFailure

    var description: String? {
        switch self {
        case .webDAVNoURL:
            return "WebDAV URL is not set up"
        case .webDAVInvalidScheme:
            return "WebDAV HTTP scheme is invalid"
        case .webDAVCreateDirectoryFailure:
            return "Failed to create a directory on WebDAV"
        case .webDAVUploadFailure:
            return "Failed to upload the file to WebDAV"
        case .dropboxUnauthorized:
            return "Dropbox account is unauthorized"
        case .dropboxInvalidLocation:
            return "Invalid Dropbox location"
        case .dropboxUploadFailure:
            return "Failed to upload the file to Dropbox"
        }
    }

}

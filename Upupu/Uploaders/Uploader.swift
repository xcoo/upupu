//
//  Uploader.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 9/2/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

protocol Uploadable {

    func upload(_ filename: String, data: Data, completion: ((_ error: UPError?) -> Void)?)

}

class Uploader {

    func directoryName(_ date: Date = Date()) -> String {
        return DateHelper.dateString(date)
    }

    class func fileStem(_ date: Date = Date()) -> String {
        return DateHelper.dateTimeString(date)
    }

}

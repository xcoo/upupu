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

    func upload(fileStem: String!, imageData: NSData, completion: ((error: Any?) -> Void)?)

}

class Uploader {

    func directoryName(date: NSDate = NSDate()) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.stringFromDate(NSDate())
    }

    func filename(date: NSDate = NSDate()) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return "\(formatter.stringFromDate(date)).jpg"
    }

}

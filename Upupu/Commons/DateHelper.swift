//
//  DateHelper.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 11/7/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

class DateHelper {

    static func dateString(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = NSLocale.system
        return formatter.string(from: date)
    }

    static func dateTimeString(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = NSLocale.system
        return formatter.string(from: date)
    }

}

//
//  String+NSString.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/30/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

extension String {

    private func asNS() -> NSString {
        return (self as NSString)
    }

    var lastPathComponent: String {
        return asNS().lastPathComponent
    }

    var length: Int {
        return self.characters.count
    }

    var pathComponents: [String] {
        return asNS().pathComponents
    }

    var pathExtension: String {
        return asNS().pathExtension
    }

    func stringByAppendingPathComponent(path: String) -> String {
        return asNS().stringByAppendingPathComponent(path)
    }

    func stringByAppendingPathExtension(ext: String) -> String? {
        return asNS().stringByAppendingPathExtension(ext)
    }

    var stringByDeletingLastPathComponent: String {
        return asNS().stringByDeletingLastPathComponent
    }

    var stringByDeletingPathExtension: String {
        return asNS().stringByDeletingPathExtension
    }

    func substringFromIndex(index: Int) -> String {
        return asNS().substringFromIndex(index)
    }

    func substringToIndex(index: Int) -> String {
        return asNS().substringToIndex(index)
    }

    func substringWithRange(range: NSRange) -> String {
        return asNS().substringWithRange(range)
    }

}

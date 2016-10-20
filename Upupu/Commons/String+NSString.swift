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

    func stringByAppendingPathComponent(_ path: String) -> String {
        return asNS().appendingPathComponent(path)
    }

    func stringByAppendingPathExtension(_ ext: String) -> String? {
        return asNS().appendingPathExtension(ext)
    }

    var stringByDeletingLastPathComponent: String {
        return asNS().deletingLastPathComponent
    }

    var stringByDeletingPathExtension: String {
        return asNS().deletingPathExtension
    }

    func substringFromIndex(_ index: Int) -> String {
        return asNS().substring(from: index)
    }

    func substringToIndex(_ index: Int) -> String {
        return asNS().substring(to: index)
    }

    func substringWithRange(_ range: NSRange) -> String {
        return asNS().substring(with: range)
    }

}

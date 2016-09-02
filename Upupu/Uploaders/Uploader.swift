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

    func upload(filename: String!, imageData: NSData!, completion: ((error: Any?) -> Void)?)

}

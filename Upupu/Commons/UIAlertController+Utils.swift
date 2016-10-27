//
//  UIAlertController+Utils.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/31/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

extension UIAlertController {

    class func showSimpleAlertIn(_ viewController: UIViewController?, title: String?,
                                 message: String?) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController?.present(alertController, animated: true, completion: nil)
    }

    class func showSimpleErrorAlertIn(_ viewController: UIViewController?, error: UPError) {
        let alertController = UIAlertController(title: "Error", message: error.description,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController?.present(alertController, animated: true, completion: nil)
    }

    class func showSettingsAlertIn(_ viewController: UIViewController?, title: String?,
                                   message: String?) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }))
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.preferredAction = okAction
        viewController?.present(alertController, animated: true, completion: nil)
    }

}

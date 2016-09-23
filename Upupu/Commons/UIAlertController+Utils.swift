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

    class func showSimpleAlertIn(viewController: UIViewController?, title: String?,
                                 message: String?) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        viewController?.presentViewController(alertController, animated: true, completion: nil)
    }

    class func showSettingsAlertIn(viewController: UIViewController?, title: String?,
                                   message: String?) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .Default,
            handler: { action in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
        }))
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        if #available(iOS 9.0, *) {
            alertController.preferredAction = okAction
        }
        viewController?.presentViewController(alertController, animated: true, completion: nil)
    }

}

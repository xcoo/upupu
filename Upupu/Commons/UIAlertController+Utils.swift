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

}

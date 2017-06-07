//
//  AccelerometerOrientation.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 6/7/17.
//  Copyright (c) 2017 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit
import CoreMotion

extension NSNotification.Name {

    static let AccelerometerOrientationDidChange = Notification.Name("AccelerometerOrientationDidChangeNotification")

}

let kAccelerometerOrientationKey = "kAccelerometerOrientationKey"

class AccelerometerOrientation {

    private(set) static var current = AccelerometerOrientation()

    private let motionManager = CMMotionManager()
    private let operationQueue = OperationQueue()

    private(set) var orientation: UIDeviceOrientation = .unknown

    init () {
        motionManager.accelerometerUpdateInterval = 0.1
    }

    func beginGeneratingDeviceOrientationNotifications() {
        motionManager.startAccelerometerUpdates(to: operationQueue, withHandler: accelerometerUpdateHandler)
    }

    func endGeneratingDeviceOrientationNotifications() {
        motionManager.stopAccelerometerUpdates()
    }

    private func accelerometerUpdateHandler(accelerometerData: CMAccelerometerData?, error: Error?) {
        guard error == nil else {
            print("Accelerometer update error:", error!)
            return
        }

        if let acceleration = accelerometerData?.acceleration {
            let angle = atan2(acceleration.y, -acceleration.x)

            var newOrientation = orientation

            if angle >= -.pi / 2 - 0.5 && angle <= -.pi / 2 + 0.5 {
                newOrientation = .portrait
            } else if angle >= -0.5 && angle <= 0.5 {
                newOrientation = .landscapeLeft
            } else if angle >= .pi / 2 - 0.5 && angle <= .pi / 2 + 0.5 {
                newOrientation = .portraitUpsideDown
            } else if angle <= -.pi + 0.5 || angle >= .pi - 0.5 {
                newOrientation = .landscapeRight
            }

            if newOrientation != orientation {
                orientation = newOrientation
                DispatchQueue.main.async {[weak self] in
                    if let self_ = self {
                        NotificationCenter.default.post(name: .AccelerometerOrientationDidChange,
                                                        object: nil,
                                                        userInfo: [kAccelerometerOrientationKey: self_])
                    }
                }
            }
        }
    }

}

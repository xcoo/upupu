//
//  UIImage+Utils.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/31/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

extension UIImage {

    func scaledImage(size: CGSize) -> UIImage? {
        let imageRef = CGImage

        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)

        var scalingSize = size
        if width > height {
            if size.width < size.height {
                scalingSize.width = size.height
                scalingSize.height = size.width
            }
        } else {
            if size.width > size.height {
                scalingSize.width = size.height
                scalingSize.height = size.width
            }
        }

        var bounds = CGRect.init(x: 0, y: 0, width: scalingSize.width, height: scalingSize.height)

        let scalingRatioW = Float(bounds.size.width) / Float(width)
        let scalingRatioH = Float(bounds.size.height) / Float(height)

        let imageSize = CGSize.init(width: width, height: height)

        var transform = CGAffineTransformIdentity
        switch imageOrientation {
        case .Up: // EXIF = 1
            transform = CGAffineTransformIdentity
        case .UpMirrored: // EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
        case .Down: // EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .DownMirrored: // EXIF = 4
            transform = CGAffineTransformMakeTranslation(0, imageSize.height)
            transform = CGAffineTransformScale(transform, 1.0, -1.0)
        case .LeftMirrored: // EXIF = 5
            let boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0)
        case .Left: // EXIF = 6
            let boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(0, imageSize.width)
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0)
        case .RightMirrored: // EXIF = 7
            let boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0)
        case .Right: // EXIF = 8
            let boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0)
        }

        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()

        if imageOrientation == .Right || imageOrientation == .Left {
            CGContextScaleCTM(context, -CGFloat(scalingRatioW), CGFloat(scalingRatioH))
            CGContextTranslateCTM(context, -CGFloat(height), 0)
        } else {
            CGContextScaleCTM(context, CGFloat(scalingRatioW), -CGFloat(scalingRatioH))
            CGContextTranslateCTM(context, 0, -CGFloat(height))
        }

        CGContextConcatCTM(context, transform)

        CGContextDrawImage(UIGraphicsGetCurrentContext(),
                           CGRect.init(x: 0, y: 0, width: width, height: height),
                           imageRef)
        let image_ = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image_
    }

}

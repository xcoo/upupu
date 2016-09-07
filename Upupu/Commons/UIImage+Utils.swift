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

    private func calcTransform(size: CGSize, orientation: UIImageOrientation) -> CGAffineTransform {
        switch orientation {
        case .Up:
            return CGAffineTransformIdentity
        case .UpMirrored:
            return CGAffineTransformScale(
                CGAffineTransformMakeTranslation(size.width, 0), -1.0, 1.0)
        case .Down:
            return CGAffineTransformRotate(
                CGAffineTransformMakeTranslation(size.width, size.height), CGFloat(M_PI))
        case .DownMirrored:
            return CGAffineTransformScale(
                CGAffineTransformMakeTranslation(0, size.height), 1.0, -1.0)
        case .LeftMirrored:
            return CGAffineTransformRotate(
                CGAffineTransformScale(
                    CGAffineTransformMakeTranslation(size.height, size.width), -1.0, 1.0),
                3.0 * CGFloat(M_PI) / 2.0)
        case .Left:
            return CGAffineTransformRotate(
                CGAffineTransformMakeTranslation(0, size.width), 3.0 * CGFloat(M_PI) / 2.0)
        case .RightMirrored:
            return CGAffineTransformRotate(
                CGAffineTransformMakeScale(-1.0, 1.0), CGFloat(M_PI) / 2.0)
        case .Right:
            return CGAffineTransformRotate(
                CGAffineTransformMakeTranslation(size.height, 0), CGFloat(M_PI) / 2.0)
        }
    }

    func scaledImage(size: CGSize) -> UIImage? {
        let imageRef = CGImage
        let currentSize = CGSize.init(width: CGImageGetWidth(imageRef),
                                      height: CGImageGetHeight(imageRef))

        var scalingSize = size
        if currentSize.width > currentSize.height {
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

        let scalingRatioW = Float(scalingSize.width) / Float(currentSize.width)
        let scalingRatioH = Float(scalingSize.height) / Float(currentSize.height)
        let transform = calcTransform(currentSize, orientation: imageOrientation)

        var newSize = CGSize.init(width: scalingSize.width, height: scalingSize.height)
        switch imageOrientation {
        case .LeftMirrored, .Left, .RightMirrored, .Right:
            let h = newSize.height
            newSize.height = newSize.width
            newSize.width = h
        default:
            break
        }

        UIGraphicsBeginImageContext(newSize)
        let context = UIGraphicsGetCurrentContext()

        if imageOrientation == .Right || imageOrientation == .Left {
            CGContextScaleCTM(context, -CGFloat(scalingRatioW), CGFloat(scalingRatioH))
            CGContextTranslateCTM(context, -CGFloat(currentSize.height), 0)
        } else {
            CGContextScaleCTM(context, CGFloat(scalingRatioW), -CGFloat(scalingRatioH))
            CGContextTranslateCTM(context, 0, -CGFloat(currentSize.height))
        }

        CGContextConcatCTM(context, transform)

        CGContextDrawImage(context, CGRect.init(origin: CGPoint.zero, size: currentSize), imageRef)
        let image_ = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image_
    }

}

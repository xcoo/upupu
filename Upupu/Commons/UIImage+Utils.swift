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

    private func calcTransform(_ size: CGSize, orientation: UIImageOrientation)
        -> CGAffineTransform {
            switch orientation {
            case .up:
                return CGAffineTransform.identity
            case .upMirrored:
                return CGAffineTransform(translationX: size.width, y: 0)
                    .scaledBy(x: -1.0, y: 1.0)
            case .down:
                return CGAffineTransform(translationX: size.width, y: size.height)
                    .rotated(by: .pi)
            case .downMirrored:
                return CGAffineTransform(translationX: 0, y: size.height)
                    .scaledBy(x: 1.0, y: -1.0)
            case .leftMirrored:
                return CGAffineTransform(translationX: size.height, y: size.width)
                    .scaledBy(x: -1.0, y: 1.0)
                    .rotated(by: 3.0 * .pi / 2.0)
            case .left:
                return CGAffineTransform(translationX: 0, y: size.width)
                    .rotated(by: 3.0 * .pi / 2.0)
            case .rightMirrored:
                return CGAffineTransform(scaleX: -1.0, y: 1.0)
                    .rotated(by: .pi / 2.0)
            case .right:
                return CGAffineTransform(translationX: size.height, y: 0)
                    .rotated(by: .pi / 2.0)
            }
    }

    func scaledImage(_ size: CGSize) -> UIImage? {
        guard let imageRef = cgImage else {
            return nil
        }

        let currentSize = CGSize.init(width: imageRef.width, height: imageRef.height)

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
        case .leftMirrored, .left, .rightMirrored, .right:
            let h = newSize.height
            newSize.height = newSize.width
            newSize.width = h
        default:
            break
        }

        UIGraphicsBeginImageContext(newSize)
        let context = UIGraphicsGetCurrentContext()

        if imageOrientation == .right || imageOrientation == .left {
            context?.scaleBy(x: -CGFloat(scalingRatioW), y: CGFloat(scalingRatioH))
            context?.translateBy(x: -CGFloat(currentSize.height), y: 0)
        } else {
            context?.scaleBy(x: CGFloat(scalingRatioW), y: -CGFloat(scalingRatioH))
            context?.translateBy(x: 0, y: -CGFloat(currentSize.height))
        }

        context?.concatenate(transform)

        context?.draw(imageRef, in: CGRect.init(origin: CGPoint.zero, size: currentSize))
        let image_ = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image_
    }

}

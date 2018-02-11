//
//  FilenameTextField.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 9/23/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import UIKit

class FilenameTextField: UITextField {

    var fileStem: String? {
        get {
            if let fileExtension = fileExtension {
                return text?.replacingOccurrences(of: "(.*)\\\(fileExtension)$",
                                                  with: "$1",
                                                  options: .regularExpression,
                                                  range: nil)
            } else {
                return text
            }
        }

        set(fileStem) {
            text = fileStem
            formatFilename()
        }
    }

    var fileExtension: String? {
        didSet { formatFilename() }
    }

    var extentionHidden = false {
        didSet { formatFilename() }
    }

    private let fileStemAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
    private let fileExtensionAttributes = [NSAttributedStringKey.foregroundColor: UIColor.gray]

    init(fileExtension: String?) {
        super.init(frame: CGRect.zero)
        self.fileExtension = fileExtension
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func formatFilename() {
        guard let stem = fileStem, !stem.isEmpty else {
            return
        }

        guard let extension_ = fileExtension, !extension_.isEmpty else {
            return
        }

        if extentionHidden {
            attributedText = NSAttributedString(string: stem, attributes: fileStemAttributes)
        } else {
            if let text = text, !text.isEmpty {
                let mainStr = NSMutableAttributedString(string: text, attributes: fileStemAttributes)
                let extensionStr = NSAttributedString(string: extension_, attributes: fileExtensionAttributes)
                mainStr.append(extensionStr)
                attributedText = mainStr
            }
        }
    }

}

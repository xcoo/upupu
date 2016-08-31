//
//  WebDAVUploader.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/30/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

class WebDAVUploader: NSObject {

    var success = false

    private let fileName: String
    private let imageData: NSData

    private var waitingOnAuthentication = false

    init(name: String, imageData: NSData) {
        self.fileName = name
        self.imageData = imageData
    }

    private func directoryName() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.stringFromDate(NSDate())
    }

    func upload() {
        success = true
        waitingOnAuthentication = true

        let baseURL: String

        // Validate server path
        guard let settingsURL = Settings.webDAVURL else {
            success = false
            return
        }
        if settingsURL[settingsURL.endIndex.advancedBy(-1)] != "/" {
            baseURL = settingsURL + "/"
        } else {
            baseURL = settingsURL
        }

        // Validate http scheme
        if !(baseURL.hasPrefix("http://") || baseURL.hasPrefix("https://")) {
            success = false
            return
        }

        // Fetch directory
        FMWebDAVRequest.requestToURL(NSURL(string: baseURL),
                                     delegate: self,
                                     endSelector: #selector(requestDidFetchDirectoryListingAndTestAuthenticationDidFinish),
                                     contextInfo: nil).fetchDirectoryListing()

        let currentRunLoop = NSRunLoop.currentRunLoop()
        while waitingOnAuthentication &&
            currentRunLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture()) {
                usleep(100000)
        }

        if !success {
            return
        }

        let directoryName = self.directoryName()
        let dirURL = "\(baseURL)\(directoryName)/"
        FMWebDAVRequest.requestToURL(NSURL(string: dirURL),
                                     delegate: self,
                                     endSelector: nil,
                                     contextInfo: nil)
            .synchronous()
            .createDirectory()

        let putURL = "\(baseURL)\(directoryName)/\(fileName).jpg"
        let data = NSData(data: imageData)
        FMWebDAVRequest.requestToURL(NSURL(string: putURL),
                                     delegate: self,
                                     endSelector: nil,
                                     contextInfo: nil)
            .synchronous()
            .putData(data)
    }

    // MARK: - FMWebDAVRequest delegate (VPRServiceRequestDelegate)

    override func request(request: FMWebDAVRequest!, didFailWithError error: NSError!) {
        success = false
    }

    override func request(request: FMWebDAVRequest!,
                          hadStatusCodeErrorWithResponse httpResponse: NSHTTPURLResponse!) {
        success = false
    }

    override func request(request: FMWebDAVRequest!,
                          didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge!) {
        guard let username = Settings.webDAVUser,
            password = Settings.webDAVPassword else {
                success = false
                waitingOnAuthentication = false
                return
        }

        if challenge.previousFailureCount == 0 {
            let cred = NSURLCredential(user: username, password: password, persistence: .ForSession)
            challenge.sender?.useCredential(cred, forAuthenticationChallenge: challenge)
        } else {
            success = false
            waitingOnAuthentication = false
        }
    }

    func requestDidFetchDirectoryListingAndTestAuthenticationDidFinish(request: FMWebDAVRequest) {
        success = request.error == nil
        waitingOnAuthentication = false
    }

}

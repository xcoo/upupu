//
//  WebDAVUploader.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/30/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

class WebDAVUploader: NSObject, Uploadable {

    private var authSucceeded = false
    private var waitingOnAuthentication = false

    private func directoryName() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.stringFromDate(NSDate())
    }

    func upload(filename: String!, imageData: NSData!, completion: ((error: Any?) -> Void)?) {
        guard imageData != nil else {
            completion?(error: "No image data")
            return
        }

        authSucceeded = true
        waitingOnAuthentication = true

        let baseURL: String

        // Validate server path
        guard let settingsURL = Settings.webDAVURL else {
            completion?(error: "Invalid WebDAV URL")
            return
        }
        if settingsURL[settingsURL.endIndex.advancedBy(-1)] != "/" {
            baseURL = settingsURL + "/"
        } else {
            baseURL = settingsURL
        }

        // Validate http scheme
        if !(baseURL.hasPrefix("http://") || baseURL.hasPrefix("https://")) {
            completion?(error: "Invalid HTTP scheme")
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

        if !authSucceeded {
            completion?(error: "Authentication failed")
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

        let dbFilename: String
        if filename == nil || filename.isEmpty {
            let now = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            dbFilename = "\(formatter.stringFromDate(now)).jpg"
        } else {
            dbFilename = "\(filename).jpg"
        }

        let putURL = "\(baseURL)\(directoryName)/\(dbFilename)"
        let data = NSData(data: imageData)
        FMWebDAVRequest.requestToURL(NSURL(string: putURL))
            .synchronous()
            .withFinishBlock({ (request) in
                if request.responseStatusCode == FMWebDAVCreatedStatusCode {
                    completion?(error: nil)
                } else {
                    completion?(error: request.responseStatusCode)
                }
            })
            .putData(data)
    }

    // MARK: - FMWebDAVRequest delegate (VPRServiceRequestDelegate)

    override func request(request: FMWebDAVRequest!, didFailWithError error: NSError!) {
        authSucceeded = false
    }

    override func request(request: FMWebDAVRequest!,
                          hadStatusCodeErrorWithResponse httpResponse: NSHTTPURLResponse!) {
        authSucceeded = false
    }

    override func request(request: FMWebDAVRequest!,
                          didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge!) {
        guard let username = Settings.webDAVUser,
            password = Settings.webDAVPassword else {
                authSucceeded = false
                waitingOnAuthentication = false
                return
        }

        if challenge.previousFailureCount == 0 {
            let cred = NSURLCredential(user: username, password: password, persistence: .ForSession)
            challenge.sender?.useCredential(cred, forAuthenticationChallenge: challenge)
        } else {
            authSucceeded = false
            waitingOnAuthentication = false
        }
    }

    func requestDidFetchDirectoryListingAndTestAuthenticationDidFinish(request: FMWebDAVRequest) {
        authSucceeded = request.error == nil
        waitingOnAuthentication = false
    }

}

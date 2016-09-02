//
//  WebDAVUploader.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/30/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

class WebDAVUploader: Uploader, Uploadable {

    private var authSucceeded = false
    private var waitingOnAuthentication = false

    func upload(fileStem: String!, imageData: NSData, completion: ((error: Any?) -> Void)?) {
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

        let now = NSDate()
        let dirName = directoryName(now)
        let dirURL = "\(baseURL)\(dirName)/"
        FMWebDAVRequest.requestToURL(NSURL(string: dirURL),
                                     delegate: self,
                                     endSelector: nil,
                                     contextInfo: nil)
            .synchronous()
            .createDirectory()

        let filename_: String
        if fileStem == nil || fileStem.isEmpty {
            filename_ = filename(now)
        } else {
            filename_ = "\(fileStem).jpg"
        }

        let putURL = "\(baseURL)\(dirName)/\(filename_)"
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

    @objc private func request(request: FMWebDAVRequest!, didFailWithError error: NSError!) {
        authSucceeded = false
    }

    @objc private func request(request: FMWebDAVRequest!,
                               hadStatusCodeErrorWithResponse httpResponse: NSHTTPURLResponse!) {
        authSucceeded = false
    }

    @objc private func request(request: FMWebDAVRequest!,
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

    @objc private func requestDidFetchDirectoryListingAndTestAuthenticationDidFinish(request: FMWebDAVRequest) {
        authSucceeded = request.error == nil
        waitingOnAuthentication = false
    }

}

//
//  DropboxUploader.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 8/30/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

class DropboxUploader: NSObject, DBSessionDelegate, DBRestClientDelegate {

    static var sharedInstance = DropboxUploader()

    private static let kDBTmpFilename = "db_tmp.jpg"

    var success = false

    private var restClient: DBRestClient?
    private var uploading = false

    override init() {
        super.init()
        startSession()
    }

    func handleURL(url: NSURL) -> Bool {
        let dbSession = DBSession.sharedSession()
        if dbSession.handleOpenURL(url) {
            if dbSession.isLinked() {
                loadAccount()
                Settings.setDropboxEnabled(true)
            }
            return true
        }
        return false
    }

    private func startSession() {
        let dbSession = DBSession(appKey: Constants.Dropbox.kDBAppKey,
                                  appSecret: Constants.Dropbox.kDBAppSecret,
                                  root: kDBRootDropbox)
        dbSession.delegate = self
        DBSession.setSharedSession(dbSession)
    }

    private func isLinked() -> Bool {
        return DBSession.sharedSession().isLinked()
    }

    func linkFromController(viewController: UIViewController) {
        DBSession.sharedSession().linkFromController(viewController)
    }

    private func makeRestClient() {
        if restClient == nil {
            restClient = DBRestClient(session: DBSession.sharedSession())
            restClient!.delegate = self
        }
    }

    func uploadWithName(filename: String!, imageData: NSData) {
        makeRestClient()

        success = true

        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dbSaveDirectory = "\(Settings.dropboxLocation())/\(formatter.stringFromDate(now))"

        let dbFilename: String
        if filename == nil || filename.isEmpty {
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            dbFilename = "\(formatter.stringFromDate(now)).jpg"
        } else {
            dbFilename = "\(filename).jpg"
        }

        let filePath = "\(NSTemporaryDirectory())\(DropboxUploader.kDBTmpFilename)"
        if imageData.writeToFile(filePath, atomically: true) {
            print("Suceed to write a temporary image file")
            print("Path: \(filePath)")
        } else {
            print("Failed to write a temporary image file")
            return
        }

        // Upload to Dropbox
        if let restClient = restClient {
            restClient.uploadFile(dbFilename, toPath: dbSaveDirectory, withParentRev: nil,
                                  fromPath:  filePath)
            uploading = true
            while uploading {
                NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.5))
            }
        }
    }

    private func removeTmpImagefile() {
        let fileManager = NSFileManager.defaultManager()
        let filePath = NSTemporaryDirectory() + DropboxUploader.kDBTmpFilename
        do {
            try fileManager.removeItemAtPath(filePath)
        } catch {
            print("Failed to remove the temporary file")
        }
    }

    private func loadAccount() {
        makeRestClient()
        restClient?.loadAccountInfo()
    }

    // MARK: - DBSessionDelegate

    @objc func sessionDidReceiveAuthorizationFailure(session: DBSession!, userId: String!) {
        print("Failed to authorize session")
    }

    // MARK: - DBRestClientDelegate

    @objc func restClient(client: DBRestClient!, uploadedFile destPath: String!,
                          from srcPath: String!, metadata: DBMetadata!) {
        print("Succeeded to upload to Dropbox")
        print("Path: \(metadata.path)")
        removeTmpImagefile()
        uploading = false
    }

    @objc func restClient(client: DBRestClient!, uploadFileFailedWithError error: NSError!) {
        print("Fail to upload to Dropbox - \(error)")
        removeTmpImagefile()
        success = false
        uploading = false
    }

    @objc func restClient(client: DBRestClient!, loadedAccountInfo info: DBAccountInfo!) {
        Settings.dropboxAccount(info.displayName)
    }
}

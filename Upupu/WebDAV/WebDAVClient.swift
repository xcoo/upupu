//
//  WebDAVClient.swift
//  Upupu
//
//  Created by Toshiki Takeuchi on 9/5/16.
//  Copyright © 2016 Xcoo, Inc. All rights reserved.
//  See LISENCE for Upupu's licensing information.
//

import Foundation

import Alamofire

class WebDAVClient {

    static func createDirectory(urlString: String) -> WebDAVRequest {
        let alamofireRequest = request("MKCOL", urlString)
        alamofireRequest.validate()
        return WebDAVRequest(alamofireRequest: alamofireRequest)
    }

    static func upload(urlString: String, data: NSData) -> WebDAVRequest {
        let alamofireRequest = Alamofire.upload(.PUT, urlString, data: data)
        alamofireRequest.validate()
        return WebDAVRequest(alamofireRequest: alamofireRequest)
    }

    private static func request(method: String, _ URLString: URLStringConvertible,
                                parameters: [String: AnyObject]? = nil,
                                encoding: ParameterEncoding = .URL,
                                headers: [String: String]? = nil) -> Alamofire.Request {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        let encodedURLRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
        return Manager.sharedInstance.request(encodedURLRequest)
    }

    private static func URLRequest(method: String, _ URLString: URLStringConvertible,
                                   headers: [String: String]? = nil) -> NSMutableURLRequest {
        let mutableURLRequest: NSMutableURLRequest

        if let request = URLString as? NSMutableURLRequest {
            mutableURLRequest = request
        } else if let request = URLString as? NSURLRequest {
            mutableURLRequest = request.URLRequest
        } else {
            mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
        }

        mutableURLRequest.HTTPMethod = method

        if let headers = headers {
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }

        return mutableURLRequest
    }
}

class WebDAVRequest {

    private let alamofireRequest: Alamofire.Request

    init(alamofireRequest: Alamofire.Request) {
        self.alamofireRequest = alamofireRequest
    }

    func authenticate(user user: String, password: String,
                             persistence: NSURLCredentialPersistence = .ForSession) -> Self {
        alamofireRequest.authenticate(user: user, password: password)
        return self
    }

    func response(completionHandler: (NSHTTPURLResponse?, NSError?) -> Void) -> Self {
        alamofireRequest.response { (_, response, _, error) in
            completionHandler(response, error)
        }
        return self
    }

}

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

extension URLRequest {

    public init(url: URLConvertible, method: String, headers: HTTPHeaders? = nil) throws {
        let url = try url.asURL()

        self.init(url: url)

        httpMethod = method

        if let headers = headers {
            for (headerField, headerValue) in headers {
                setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
    }

}

class WebDAVClient {

    static func createDirectory(_ url: URLConvertible) -> WebDAVRequest {
        do {
            let alamofireRequest = try request(url, method: "MKCOL")
            alamofireRequest.validate()
            return WebDAVRequest(alamofireRequest: alamofireRequest)
        } catch {
            return WebDAVRequest(error: error)
        }
    }

    static func upload(_ url: URLConvertible, data: Data) -> WebDAVRequest {
        let alamofireRequest = Alamofire.upload(data, to: url, method: .put)
        alamofireRequest.validate()
        return WebDAVRequest(alamofireRequest: alamofireRequest)
    }

    private static func request(_ url: URLConvertible,
                                method: String,
                                parameters: [String: AnyObject]? = nil,
                                encoding: ParameterEncoding = URLEncoding.default,
                                headers: [String: String]? = nil) throws -> DataRequest {
        let urlRequest = try URLRequest(url: url, method: method, headers: headers)
        let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
        return SessionManager.default.request(encodedURLRequest)
    }
}

class WebDAVRequest {

    private let alamofireRequest: DataRequest?

    private let error: Error?

    init(alamofireRequest: DataRequest) {
        self.alamofireRequest = alamofireRequest
        error = nil
    }

    init(error: Error) {
        alamofireRequest = nil
        self.error = error
    }

    func authenticate(user: String, password: String, persistence: URLCredential.Persistence = .forSession) -> Self {
        alamofireRequest?.authenticate(user: user, password: password)
        return self
    }

    func response(_ completionHandler: @escaping (HTTPURLResponse?, Error?) -> Void) -> Self {
        guard let alamofireRequest = alamofireRequest else {
            completionHandler(nil, error)
            return self
        }

        alamofireRequest.response { dataResponse in
            completionHandler(dataResponse.response, dataResponse.error)
        }

        return self
    }

}

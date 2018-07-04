//
//  MockURLSession.swift
//  RemoteTests
//
//  Created by Dmitry Klimkin on 18/9/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation

@testable import Remote

final class MockURLTask: URLSessionDataTaskProtocol {
    let file: String
    let handler: DataTaskResult

    init(file: String, handler: @escaping DataTaskResult) {
        self.file = file
        self.handler = handler
    }

    func resume() {
        let bundle = Bundle(for: type(of: self))

        guard let path = bundle.path(forResource: file, ofType: "json") else {
            handler(nil, nil, NSError(domain: "Network error: Unable to fine json file", code: 1000, userInfo: nil))

            return
        }

        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "2.0", headerFields: nil)

            handler(data, response, nil)
        } catch {

        }
    }

    func cancel() {

    }
}

final class MockURLSession: URLSessionProtocol {
    func enableDebugMode() {

    }

    func updateCredential(to credential: URLCredential, for host: String, port: Int) {

    }

    func createTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return MockURLTask(file: "get", handler: completionHandler)
    }
}

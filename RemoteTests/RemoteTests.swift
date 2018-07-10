//
//  RemoteTests.swift
//  RemoteTests
//
//  Created by Dmitry Klimkin on 22/12/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import XCTest
import When

@testable import Remote

final class RemoteTests: XCTestCase {
    let environment = Environment("test",
                                  url: URL(string: "https://httpbin.org")!,
                                  headers: ["User-Agent":       "iOS-tests",
                                            "Content-Encoding": "UTF-8",
                                            "Content-Type":     "application/json",
                                            "Accept":           "application/json",
                                            "x-pretty-print":   "2"])
    let authToken = "123456"
    let session = Session.default

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGet() {
        let config = ServiceConfig(environment: environment)

        session.auth = .token(authToken)

        let service   = HttpBinService(config, session: session)
        let testValue = "654321  ://0&"
        let expect    = expectation(description: "Testing GET request")

        GetOperation(user: testValue).execute(in: service)
            .done { response in
                var isSuccess = false

                if let value = response.args?.hash {
                    XCTAssertEqual(value, testValue)
                    XCTAssertEqual(response.headers.authorization, "Bearer " + self.authToken)

                    isSuccess = true
                }

                XCTAssertTrue(isSuccess)
                expect.fulfill()
            }.fail { error in
                XCTFail(String(describing: error))
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Expectation has timed out with error: \(error)")
            }
        }
    }

    func testPost() {
        let config = ServiceConfig(environment: environment)

        session.auth = .token(authToken)

        let service   = HttpBinService(config, session: session)
        let login     = "654321"
        let pass      = "1234567890"
        let expect    = expectation(description: "Testing Post request")

        PostOperation(user: login, password: pass).execute(in: service)
            .done { response in
                var isSuccess = false

                if let value = response.args?.hash {
                    XCTAssertEqual(value, login)

                    if let loginValue = response.json?.login {
                        XCTAssertEqual(loginValue, login)

                        if let passValue = response.json?.pass {
                            XCTAssertEqual(passValue, pass)
                            XCTAssertEqual(response.headers.authorization, "Bearer " + self.authToken)

                            isSuccess = true
                        }
                    }
                }

                XCTAssertTrue(isSuccess)
                expect.fulfill()
            }.fail { error in
                XCTFail(String(describing: error))
        }

        waitForExpectations(timeout: 20) { error in
            if let error = error {
                XCTFail("Expectation has timed out with error: \(error)")
            }
        }
    }

    func testPostMultipart() {
        let config = ServiceConfig(environment: environment)

        session.auth = .token(authToken)

        let service   = HttpBinService(config, session: session)
        let login     = "654321"
        let pass      = "1234567890"
        let expect    = expectation(description: "Testing Post Multipart request")

        PostMultipartOperation(user: login, password: pass).execute(in: service)
            .done { response in
                var isSuccess = false

                if let value = response.args?.hash {
                    XCTAssertEqual(value, login)

                    if let loginValue = response.form?.login {
                        XCTAssertEqual(loginValue, login)

                        if let passValue = response.form?.pass {
                            XCTAssertEqual(passValue, pass)
                            XCTAssertEqual(response.headers.authorization, "Bearer " + self.authToken)

                            if let dataValue = response.form?.data {
                                XCTAssertEqual(dataValue, login + pass)

                                if let zipValue = response.form?.zip {
                                    XCTAssertEqual(zipValue, pass + login)

                                    isSuccess = true
                                }
                            }
                        }
                    }
                }

                XCTAssertTrue(isSuccess)
                expect.fulfill()
            }.fail { error in
                XCTFail(String(describing: error))
        }

        waitForExpectations(timeout: 20) { error in
            if let error = error {
                XCTFail("Expectation has timed out with error: \(error)")
            }
        }
    }

    func testImage() {
        let config = ServiceConfig(environment: environment)

        session.auth = .token(authToken)

        let service   = HttpBinService(config, session: session)
        let testValue = "654321"
        let expect    = expectation(description: "Testing GET Image request")

        ImageOperation(id: testValue).execute(in: service)
            .done { image in
                var isSuccess = false

                guard let image = image else {
                    XCTFail("No image")

                    return
                }

                if image.size.width == 239 && image.size.height == 178 {
                    isSuccess = true
                }

                XCTAssertTrue(isSuccess)
                expect.fulfill()
            }.fail { error in
                XCTFail(String(describing: error))
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Expectation has timed out with error: \(error)")
            }
        }
    }

    func testGetLocalJSON() {
        let config = ServiceConfig(environment: environment)

        let service   = HttpBinService(config, session: MockURLSession())
        let testValue = "654321"
        let expect    = expectation(description: "Testing GET request")

        GetOperation(user: testValue).execute(in: service)
            .done { response in
                var isSuccess = false

                if let value = response.args?.hash {
                    XCTAssertEqual(value, testValue)
                    XCTAssertEqual(response.headers.authorization, "Bearer " + self.authToken)

                    isSuccess = true
                }

                XCTAssertTrue(isSuccess)
                expect.fulfill()
            }.fail { error in
                XCTFail(String(describing: error))
        }

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("Expectation has timed out with error: \(error)")
            }
        }
    }
}

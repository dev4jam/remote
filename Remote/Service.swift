//
//  Service.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation
import When

/// Service is a concrete implementation of the ServiceProtocol
open class Service: NSObject, ServiceProtocol {

    /// Configuration
    public let configuration: ServiceConfig

    /// Session headers
    public var headers: HeadersDict

    /// URL session
    public let session: URLSessionProtocol

    /// Internal processing queue
    private let networkingQueue = DispatchQueue(label: "network-processing-queue")

    /// Initialize a new service with given configuration
    ///
    /// - Parameter configuration: configuration. If `nil` is passed attempt to load configuration from your app's Info.plist
    public required init(_ configuration: ServiceConfig, session: URLSessionProtocol) {
        self.configuration = configuration
        self.headers = self.configuration.headers // fillup with initial headers
        self.session = session
    }

    /// Execute a request and return a promise with the response
    ///
    /// - Parameters:
    ///   - request: request to execute
    ///   - retry: retry attempts. If `nil` only one attempt is made. Default value is `nil`.
    /// - Returns: Promise
    /// - Throws: throw an exception if operation cannot be executed
    public func execute(_ request: RequestProtocol?, cacheKey: String?) -> Promise<ResponseProtocol> {
        // Wrap in a promise the request itself
        let promise = Promise<ResponseProtocol>()

        networkingQueue.async {
            guard let rq = request else { // missing request
                // yield this thread
                promise.reject(NetworkError.missingEndpoint("no request specified"))
                return
            }

            do {
                let urlRequest = try rq.urlRequest(in: self)

                let task: URLSessionDataTaskProtocol = self.session.createTask(with: urlRequest) { data, response, error in
                    let parsedResponse = Response(urlResponse: response, data: data, request: rq)

                    switch parsedResponse.type {
                    case .success: // success
                        promise.resolve(parsedResponse)
                    case .error(let code): // failure
                        if code == 23 {
                            promise.reject(NetworkError.authorisationExpired("session expired"))
                        } else if code == 401 {
                            promise.reject(NetworkError.notAuthorised("request is not authorized"))
                        } else if parsedResponse.data != nil {
                            promise.resolve(parsedResponse)
                        } else {
                            promise.reject(NetworkError.genericError("received error code: \(code)"))
                        }
                    case .noResponse:  // no response
                        promise.reject(NetworkError.noResponse("no response from server"))
                    }
                }

                task.resume()
            } catch (let error) {
                promise.reject(error)
            }
        }

        return promise
    }

    /// Updates existing ssl pinning credential
    ///
    /// - Parameter credential: credential to set
    public func updateCredential(to credential: URLCredential) {
        guard let host = configuration.url.host else { return }

        var port = 443

        if let configPort = configuration.url.port  {
            port = configPort
        }

        session.updateCredential(to: credential, for: host, port: port)
    }
}

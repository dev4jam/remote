//
//	Service.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation
import RxSwift

/// Service is a concrete implementation of the ServiceProtocol
open class Service: ServiceProtocol {

	/// Configuration
	public var configuration: ServiceConfig
	
	/// Session headers
	public var headers: HeadersDict
	
    /// URL session
    public var session: URLSessionProtocol

	/// Initialize a new service with given configuration
	///
	/// - Parameter configuration: configuration.
    ///   If `nil` is passed attempt to load configuration from your app's Info.plist
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
	public func execute(_ request: RequestProtocol?, cacheKey: String?) -> Observable<ResponseProtocol> {
		// Wrap in a promise the request itself
        let observable = Observable<ResponseProtocol>.create { (observer) -> Disposable in
            var dataTask: URLSessionDataTaskProtocol?
            
            guard let rq = request else { // missing request
                // yield this thread
                observer.onError(NetworkError.missingEndpoint("no request specified"))
                
                return Disposables.create()
            }
            
            let cache = ModelCache(cacheContainerId: "cache")

            if let cacheKey = cacheKey, let data = cache.loadResponse(for: cacheKey) {
                let response = Response(cachedData: data, request: rq)
                
                observer.on(.next(response))
            }
            
            do {
                let urlRequest = try rq.urlRequest(in: self)
                
                let task = self.session.createTask(with: urlRequest) { data, response, error in
                    let parsedResponse = Response(urlResponse: response, data: data, request: rq)
                    
                    switch parsedResponse.type {
                    case .success: // success
                        observer.on(.next(parsedResponse))
                    case .error(let code): // failure
                        if code == 401 {
                            observer.onError(NetworkError.notAuthorised("request is not authorized"))
                        } else {
                            observer.onError(NetworkError.genericError("received error code: \(code)"))
                        }
                    case .noResponse:  // no response
                        observer.onError(NetworkError.noResponse("no response from server"))
                    }
                }
                
                dataTask = task

                task.resume()
            } catch (let error) {
                observer.onError(error)
            }
            
            return Disposables.create {
                guard let task = dataTask else { return }
                
                task.cancel()
            }
        }

        return observable
	}
}

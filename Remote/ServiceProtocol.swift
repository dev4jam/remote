//
//	ServiceProtocol.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation
import RxSwift

public protocol ServiceProtocol {
	
	/// This is the configuration used by the service
	var configuration: ServiceConfig { get }
	
	/// Headers used by the service. These headers are mirrored automatically
	/// to any Request made using the service. You can replace or remove it
	/// by overriding the `willPerform()` func of the `Request`.
	/// Session headers initially also contains global headers set by related server configuration.
	var headers: HeadersDict { get }
    
    /// This is session context (URLSession / MockSession)
    var session: URLSessionProtocol { get }
	
	/// Initialize a new service with specified configuration
	///
	/// - Parameter configuration: configuration to use
    init(_ configuration: ServiceConfig, session: URLSessionProtocol)

	/// Execute a request and return a promise with a response
	///
	/// - Parameter request: request to execute
	/// - Returns: Promise with response
    func execute(_ request: RequestProtocol?, cacheKey: String?) -> Observable<ResponseProtocol>

}

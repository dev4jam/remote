//
//	ServiceConfig.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation

/// This class is used to configure network connection with a backend server
public final class ServiceConfig: CustomStringConvertible, Equatable {
		
    // This is the environment configuration
    private(set) var environment: Environment
    
    private var internalHeaders: HeadersDict = [:]
    
	/// These are the global headers which must be included in each session of the service
    public var headers: HeadersDict {
        set {
            internalHeaders = newValue
        }
        get {
            var envHeaders = environment.headers
            
            internalHeaders.forEach { (key, value) in envHeaders[key] = value }
            
            return envHeaders
        }
    }
    
	/// Cache policy you want apply to each request done with this service
	/// By default is `.useProtocolCachePolicy`.
	public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
	
	/// Global timeout for any request. If you want, you can override it in Request
	/// Default value is 15 seconds.
	public var timeout: TimeInterval = 15.0

    /// Readonly host url
    public var url: URL {
        return environment.url
    }

	/// Initialize a new service configuration
	///
	/// - Parameters:
	///   - name: name of the configuration (its just for debug purpose)
	///   - urlString: base url of the service
	///   - api: path to APIs service endpoint
    public init(environment: Environment?) {
        if let env = environment {
            self.environment = env
        } else {
            self.environment = Environment.default
        }        
	}
	
	/// Attempt to load server configuration from Info.plist
	///
	/// - Returns: ServiceConfig if Info.plist of the app can be parsed, `nil` otherwise
	public static func appConfig() -> ServiceConfig? {
        return ServiceConfig(environment: EnvironmentType.config.environment)
	}
		
	/// Readable description
	public var description: String {
		return environment.description
	}
	
	/// A Service configuration is equal to another if both url and path to APIs endpoint are the same.
	/// This comparison ignore service name.
	///
	/// - Parameters:
	///   - lhs: configuration a
	///   - rhs: configuration b
	/// - Returns: `true` if equals, `false` otherwise
	public static func == (lhs: ServiceConfig, rhs: ServiceConfig) -> Bool {
		return lhs.environment.url.absoluteString.lowercased() == rhs.environment.url.absoluteString.lowercased()
	}
}

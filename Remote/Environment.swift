//
//  Environment.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation

public struct Environment {
    /// Name of the environment
    public var name: String
    
    /// Base URL of the environment
    public var url: URL
    
    /// This is the list of common headers which will be part of each Request
    /// Some headers value maybe overwritten by Request's own headers
    public var headers: HeadersDict = [:]
    
    /// Cache policy
    public var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    /// Initialize a new Environment
    ///
    /// - Parameters:
    ///   - name: name of the environment
    ///   - host: base url
    public init(_ name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
    /// Initialize a new Environment
    ///
    /// - Parameters:
    ///   - name:    name of the environment
    ///   - host:    base url
    ///   - headers: default http headers
    public init(_ name: String, url: URL, headers: HeadersDict) {
        self.name    = name
        self.url     = url
        self.headers = headers
    }
}

extension Environment: CustomStringConvertible {
    public var description: String {
        return "\(self.name): \(self.url.absoluteString)"
    }
}

public extension Environment {
    static var `default`: Environment {
        return EnvironmentType.prod.environment
    }
    
    /// Initialize a new service configuration by looking at paramters
    public static func load() -> Environment {
        return EnvironmentType.config.environment
    }
}

public enum EnvironmentType: String {
    private enum Config: String {
        case endpoint    =    "endpoint"
        case base        =    "base"
        case pathAPI     =    "path"
        case name        =    "name"
        case headers     =    "headers"
    }

    case dev, prod, config
    
    public var environment: Environment {
        var bundleId = ""
        
        if let mainBundleId = Bundle.main.bundleIdentifier {
            bundleId = mainBundleId
        }

        let defaultHeaders = ["User-Agent": "iOS-" + self.rawValue + "-" + bundleId,
                              "Content-Encoding": "UTF-8",
                              "Content-Type": "application/json",
                              "Accept": "application/json",
                              "x-pretty-print": "2"]
        
        let defaultEnv = Environment("Production", url: URL(string: "https://prod.com")!, headers: defaultHeaders)

        switch self {
        case .dev:
            return Environment("Dev", url: URL(string: "https://dev.com")!, headers: defaultHeaders)
        case .prod:
            return defaultEnv
        case .config:
            let endpoint = Bundle.main.object(forInfoDictionaryKey: EnvironmentType.Config.endpoint.rawValue)
            
            guard let appCfg = endpoint as? [String: Any] else {
                return defaultEnv
            }
            
            guard let name = appCfg[EnvironmentType.Config.name.rawValue] as? String else {
                return defaultEnv
            }
            
            guard let base = appCfg[EnvironmentType.Config.base.rawValue] as? String else {
                return defaultEnv
            }
            
            var headers: HeadersDict = defaultHeaders

            // Attempt to read a fixed list of headers from configuration
            if let fixedHeaders = appCfg[EnvironmentType.Config.headers.rawValue] as? HeadersDict {
                headers = fixedHeaders
            }

            return Environment(name, url: URL(string: base)!, headers: headers)
        }
    }
}

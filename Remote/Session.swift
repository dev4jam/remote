//
//  Session.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation

public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

public typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

public enum SessionAuth {
    case token(String)
    case basic(String, String)
}

public protocol URLSessionProtocol {
    func createTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
    func validSessionAuth() -> SessionAuth?
    func updateSessionWith(auth: SessionAuth?)
    func updateCredential(to credential: URLCredential, for host: String, port: Int)
}

extension URLSessionProtocol {
    public func validSessionAuth() -> SessionAuth? {
        return nil
    }
    
    public func updateSessionWith(auth: SessionAuth?) {
        
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }

extension URLSession: URLSessionProtocol {
    public func createTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }
    
    public func updateCredential(to credential: URLCredential, for host: String, port: Int) {
        let protectionSpace = URLProtectionSpace(host: host, port: port, protocol: "https",
                                                 realm: nil,
                                                 authenticationMethod: NSURLAuthenticationMethodClientCertificate)
        
        URLCredentialStorage.shared.set(credential, for: protectionSpace)
        configuration.urlCredentialStorage?.set(credential, for: protectionSpace)
    }
}

public class Session: URLSessionProtocol {
    public var auth: SessionAuth?
    
    public static let `default`: Session = Session()
    
    private let session: URLSession
    
    public func createTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return session.dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }
    
    public func validSessionAuth() -> SessionAuth? {
        return auth
    }
    
    public func updateSessionWith(auth: SessionAuth?) {
        self.auth = auth
    }
    
    public init(enableDebug: Bool = false) {
        session = URLSession.shared
        
        if enableDebug {
            Sniffer.enable(in: session.configuration)
        }
    }
    
    public init(with delegate: URLSessionDelegate?, enableDebug: Bool = false) {
        let configuration = URLSessionConfiguration.default
        
        if enableDebug {
            Sniffer.enable(in: configuration)
        }
        
        session = URLSession(configuration: configuration,
                             delegate: delegate,
                             delegateQueue: OperationQueue.main)
    }
    
    public func updateCredential(to credential: URLCredential, for host: String, port: Int) {
        session.updateCredential(to: credential, for: host, port: port)
    }
}

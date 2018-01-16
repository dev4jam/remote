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
    public func createTask(with request: URLRequest,
                           completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }
}

public class Session: URLSessionProtocol {
    public var auth: SessionAuth?

    public static let `default`: Session = Session()
    
    private let session: URLSession
    
    public func createTask(with request: URLRequest,
                           completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return session.dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }

    public func validSessionAuth() -> SessionAuth? {
        return auth
    }
    
    public func updateSessionWith(auth: SessionAuth?) {
        self.auth = auth
    }
    
    public init() {
        session = URLSession.shared
    }
    
    public init(with delegate: URLSessionDelegate?) {
        session = URLSession(configuration: URLSessionConfiguration.default,
                             delegate: delegate,
                             delegateQueue: OperationQueue.main)
    }
}

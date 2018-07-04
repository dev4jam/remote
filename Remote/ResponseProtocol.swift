//
//	ResponseProtocol.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation

public protocol ResponseProtocol {
	
	/// Type of response (success or failure)
	var type: Response.Result { get }
		
	/// Request
	var request: RequestProtocol { get }
	
	/// Return the http url response
	var httpResponse: HTTPURLResponse? { get }
	
	/// Return HTTP status code of the response
	var httpStatusCode: Int? { get }

	/// Return the raw Data instance response of the request
	var data: Data? { get }
    		
	/// Attempt to decode Data received from server and return a String object.
	/// If it fails it return `nil`.
	/// Call is not cached but evaluated at each call.
	/// If no encoding is specified, `utf8` is used instead.
	///
	/// - Parameter encoding: encoding of the data
	/// - Returns: String or `nil` if failed
	func toString(_ encoding: String.Encoding?) -> String?
}

public class Response: ResponseProtocol {

	/// Type of response
	///
	/// - success: success
	/// - error: error
	public enum Result {
		case success(_: Int)
		case error(_: Int)
		case noResponse
		
		private static let successCodes: Range<Int> = 200..<299
		
		public static func from(response: HTTPURLResponse?) -> Result {
			guard let r = response else {
				return .noResponse
			}
			return (Result.successCodes.contains(r.statusCode) ? .success(r.statusCode) : .error(r.statusCode))
		}
        		
		public var code: Int? {
			switch self {
			case .success(let code): 	return code
			case .error(let code):		return code
			case .noResponse:			return nil
			}
		}
	}
	
	/// Type of result
	public let type: Response.Result
	
	/// Status code of the response
	public var httpStatusCode: Int? {
		return self.type.code
	}
	
	/// HTTPURLResponse
	public let httpResponse: HTTPURLResponse?

	/// Raw data of the response
	public var data: Data?
	
	/// Request executed
	public let request: RequestProtocol

	/// Initialize a new response from Alamofire response
	///
	/// - Parameters:
	///   - response: response
	///   - request: request
    public init(urlResponse response: URLResponse?, data: Data?, request: RequestProtocol) {
        let httpResponse = response as? HTTPURLResponse
        
		self.type = Result.from(response: httpResponse)
		self.httpResponse = httpResponse
		self.data = data
		self.request = request
	}

	public func toString(_ encoding: String.Encoding? = nil) -> String? {
		guard let d = self.data else { return nil }
		return String(data: d, encoding: encoding ?? .utf8)
	}
}

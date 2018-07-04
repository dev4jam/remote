//
//  Request.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.

import Foundation

/// Define what kind of HTTP method must be used to carry out the `Request`
///
/// - get: get (no body is allowed inside)
/// - post: post
/// - put: put
/// - delete: delete
/// - patch: patch
public enum RequestMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
    case patch  = "PATCH"
}

public struct MultipartData {
    public let parameters: [String: Any]
    public let files: [MultipartDataFile]

    public init(parameters: [String: Any], files: [MultipartDataFile]) {
        self.parameters = parameters
        self.files = files
    }
}

public struct MultipartDataFile {
    public let name: String
    public let mimeType: String
    public let data: Data

    public init(name: String, mimeType: String, data: Data) {
        self.name = name
        self.mimeType = mimeType
        self.data = data
    }
}

/// This define how the body should be encoded
///
/// - none: no transformation is applied, data is sent raw as received in `body` param of the request.
/// - json: attempt to serialize a `Dictionary` or a an `Array` as `json`. Other types are not supported and throw an exception.
/// - urlEncoded: it expect a `Dictionary` as input and encode it as url encoded string into the body.
/// - custom->: custom serializer. `Any` is accepted, `Data` is expected as output.
public struct RequestBody {

    /// Data to carry out into the body of the request
    public let data: Any

    /// Type of encoding to use
    public let encoding: Encoding

    /// Encoding type
    ///
    /// - raw: no encoding, data is sent as received
    /// - json: json encoding
    /// - urlEncoded: url encoded string
    /// - custom: custom serialized data
    public enum Encoding {
        case rawData
        case rawString(_: String.Encoding?)
        case json
        case urlEncoded(_: String.Encoding?)
        case multipart(String)
        case custom(_: CustomEncoder)

        /// Encoder function typealias
        public typealias CustomEncoder = ((Any) -> (Data))
    }

    /// Private initializa a new body
    ///
    /// - Parameters:
    ///   - data: data
    ///   - encoding: encoding type
    private init(_ data: Any, as encoding: Encoding = .json) {
        self.data = data
        self.encoding = encoding
    }

    /// Create a new body which will be encoded as JSON
    ///
    /// - Parameter data: any serializable to JSON object
    /// - Returns: RequestBody
    public static func json(_ data: Any) -> RequestBody {
        return RequestBody(data, as: .json)
    }

    /// Create a new body which will be encoded as url encoded string
    ///
    /// - Parameters:
    ///   - data: a string of encodable data as url
    ///   - encoding: encoding type to transform the string into data
    /// - Returns: RequestBody
    public static func urlEncoded(_ data: ParametersDict, encoding: String.Encoding? = .utf8) -> RequestBody {
        return RequestBody(data, as: .urlEncoded(encoding))
    }

    /// Create a new body which will be sent in raw form
    ///
    /// - Parameter data: data to send
    /// - Returns: RequestBody
    public static func raw(data: Data) -> RequestBody {
        return RequestBody(data, as: .rawData)
    }

    /// Create a new body which will be sent as plain string encoded as you set
    ///
    /// - Parameter data: data to send
    /// - Returns: RequestBody
    public static func raw(string: String, encoding: String.Encoding? = .utf8) -> RequestBody {
        return RequestBody(string, as: .rawString(encoding))
    }

    /// Create a new body which will be sent as multipart encoded data
    ///
    /// - Parameter:
    ///   - boundary: boundary key
    ///   - payload: payload to send
    /// - Returns: RequestBody
    public static func multipart(boundary: String, payload: MultipartData) -> RequestBody {
        return RequestBody(payload, as: .multipart(boundary))
    }

    /// Create a new body which will be encoded with a custom function.
    ///
    /// - Parameters:
    ///   - data: data to encode
    ///   - encoder: encoder function
    /// - Returns: RequestBody
    public static func custom(_ data: Data, encoder: @escaping Encoding.CustomEncoder) -> RequestBody {
        return RequestBody(data, as: .custom(encoder))
    }

    /// Encoded data to carry out with the request
    ///
    /// - Returns: Data
    public func encodedData() throws -> Data {
        switch self.encoding {
        case .rawData:
            return self.data as! Data
        case .rawString(let encoding):
            guard let string = (self.data as! String).data(using: encoding ?? .utf8) else {
                throw NetworkError.dataIsNotEncodable("can't encode data")
            }
            return string
        case .json:
            return try JSONSerialization.data(withJSONObject: self.data, options: .prettyPrinted)
        case .urlEncoded(let encoding):
            let encodedString = try (self.data as! ParametersDict).urlEncodedString()
            guard let data = encodedString.data(using: encoding ?? .utf8) else {
                throw NetworkError.dataIsNotEncodable(encodedString)
            }
            return data
        case .multipart(let boundary):
            guard let payload = data as? MultipartData else {
                throw NetworkError.dataIsNotEncodable("can't encode data")
            }

            let body = NSMutableData()
            let boundaryPrefix = "--\(boundary)\r\n"

            for (key, value) in payload.parameters {
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }

            for file in payload.files {
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(file.name)\"\r\n")
                body.appendString("Content-Type: \(file.mimeType)\r\n\r\n")
                body.append(file.data)
                body.appendString("\r\n")
            }

            body.appendString("--\(boundary)--\r\n")

            return body as Data
        case .custom(let encodingFunc):
            return encodingFunc(self.data)
        }
    }

    /// Return the representation of the body as `String`
    ///
    /// - Parameter encoding: encoding use to read body's data. If not specified `utf8` is used.
    /// - Returns: String
    /// - Throws: throw an exception if string cannot be decoded as string
    public func encodedString(_ encoding: String.Encoding = .utf8) throws -> String {
        let encodedData = try self.encodedData()
        guard let stringRepresentation = String(data: encodedData, encoding: encoding) else {
            throw NetworkError.stringFailedToDecode("can't encode data")
        }
        return stringRepresentation
    }
}

public class Request: RequestProtocol, CustomStringConvertible {
    /// Endpoint for request
    public var endpoint: String

    /// Body of the request
    public var body: RequestBody?

    /// HTTP method of the request
    public var method: RequestMethod?

    /// Fields of the request
    public var fields: ParametersDict?

    /// URL of the request
    public var urlParams: ParametersDict?

    /// Headers of the request
    public var headers: HeadersDict?

    /// Cache policy
    public var cachePolicy: URLRequest.CachePolicy?

    /// Timeout of the request
    public var timeout: TimeInterval?

    public var isCacheable: Bool

    /// Initialize a new request
    ///
    /// - Parameters:
    ///   - method: HTTP Method request (if not specified, `.get` is used)
    ///   - endpoint: endpoint of the request
    ///   - params: paramters to replace in endpoint
    ///   - fields: fields to append inside the url
    ///   - body: body to set
    public init(method: RequestMethod = .get, endpoint: String = "",
                params: ParametersDict? = nil, fields: ParametersDict? = nil,
                body: RequestBody? = nil, isCacheable: Bool = false) {
        self.method      = method
        self.endpoint    = endpoint
        self.urlParams   = params
        self.fields      = fields
        self.body        = body
        self.isCacheable = isCacheable
        self.headers     = [
            "Content-Encoding": "UTF-8",
            "Content-Type":     "application/json",
            "Accept":           "application/json",
            "x-pretty-print":   "2"
        ]
    }

    public var description: String {
        var text = "\(method?.rawValue ?? "") endpoint: \(endpoint)"

        do {
            if let f = fields {
                let fText = try f.urlEncodedString()

                text += "\nFields: " + fText
            }
        } catch {
        }

        do {
            if let f = urlParams {
                let fText = try f.urlEncodedString()

                text += "\nURL Params: " + fText
            }
        } catch {
        }

        return text
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            append(data)
        }
    }
}

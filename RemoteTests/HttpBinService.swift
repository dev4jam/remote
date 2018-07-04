//
//  HttpBinService.swift
//  RemoteTests
//
//  Created by Dmitry Klimkin on 22/12/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation
import UIKit
import When

@testable import Remote

struct HttpBinResponse: Codable {
    enum ValueType: Int, Codable {
        case valueInt, valueDate, valueString
    }

    enum KeyType: String, Codable {
        case keyInt, keyDate, keyString
    }

    struct Args: Codable {
        let login:     String?
        let pass:      String?
        let date:      Date?
        let float:     Float?
        let double:    Double?
        let bool:      Bool?
        let keyType:   KeyType?
        let valueType: ValueType?
        let hash:      String?
    }

    struct Form: Codable {
        let login:     String?
        let pass:      String?
        let date:      Date?
        let float:     Float?
        let double:    Double?
        let bool:      Bool?
        let keyType:   KeyType?
        let valueType: ValueType?
        let hash:      String?
        let data:      String?
        let zip:       String?
    }

    struct JSON: Codable {
        let login:     String?
        let pass:      String?
        let date:      Date?
        let float:     Float?
        let double:    Double?
        let bool:      Bool?
        let keyType:   KeyType?
        let valueType: ValueType?
        let hash:      String?
    }

    struct Headers: Codable {
        let userAgent: String
        let contentEncoding: String?
        let contentType: String?
        let accept: String
        let authorization: String?

        enum CodingKeys: String, CodingKey {
            case userAgent       = "User-Agent"
            case contentEncoding = "Content-Encoding"
            case contentType     = "Content-Type"
            case accept          = "Accept"
            case authorization   = "Authorization"
        }
    }

    let args:    Args?
    let form:    Form?
    let json:    JSON?
    let headers: Headers
    let origin:  String
    let url:     String
}

final class GetOperation: ModelOperation<HttpBinResponse> {
    public init(user: String) {
        super.init()

        self.request = Request(method: .get, endpoint: "/get", params: nil, fields: ["hash": user], body: nil)
    }
}

final class PostOperation: ModelOperation<HttpBinResponse> {
    public init(user: String, password: String) {
        super.init()

        let data = ["login" : user, "pass" : password]
        let body = RequestBody.json(data)

        self.request = Request(method: .post, endpoint: "/post", params: nil, fields: ["hash": user], body: body)
    }
}

final class PostMultipartOperation: ModelOperation<HttpBinResponse> {
    public init(user: String, password: String) {
        super.init()

        let boundary = "Boundary-" + UUID().uuidString
        let file1 = MultipartDataFile(name: "data",
                                      mimeType: "text/plain",
                                      data: (user + password).data(using: .utf8)!)
        let file2 = MultipartDataFile(name: "zip",
                                      mimeType: "application/x-zip-compressed",
                                      data: (password + user).data(using: .utf8)!)
        let data = ["login" : user, "pass" : password]
        let multipartData = MultipartData(parameters: data, files: [file1, file2])
        let body = RequestBody.multipart(boundary: boundary, payload: multipartData)

        self.request = Request(method: .post, endpoint: "/post", params: nil, fields: ["hash": user], body: body)

        request?.headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }
}

final class ImageOperation: OperationProtocol {
    public typealias DataType = UIImage?

    /// Request
    public var request: RequestProtocol?

    public init(id: String) {
        self.request = Request(method: .get, endpoint: "/image/jpeg", params: nil, fields: ["hash": id], body: nil)
    }

    public func execute(in service: ServiceProtocol) -> Promise<UIImage?> {
        return service.execute(request, cacheKey: nil).then { response -> UIImage? in
            guard let data = response.data else {
                throw NetworkError.missingData("response with no data")
            }

            return UIImage(data: data)
        }
    }
}

class HttpBinService: Service {
}


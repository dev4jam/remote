//
//	Operations.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation
import RxSwift

/// Model Operation, return a response as Decodable Model
open class ModelOperation<Output: Decodable>: OperationProtocol {
	public typealias DataType = Output
	
	/// Request
	public var request: RequestProtocol?
		
	/// Init
	public init() { }
    
	/// Execute a request and return your specified model `Output`.
	///
	/// - Parameters:
	///   - service: service to use
	/// - Returns: Promise
    public func execute(in service: ServiceProtocol) -> Observable<Output> {
        let decoder     = JSONDecoder()
        let cache       = ModelCache(cacheContainerId: "cache")
        let cacheKey    = String(describing: Output.self)
        let isCacheable = request?.isCacheable ?? false

        let observable = service.execute(request, cacheKey: cacheKey).map({ response -> Output in
            guard let data = response.data else {
                throw NetworkError.missingData("response with no data")
            }
            
            if !response.isCached && isCacheable {
                switch response.type {
                case .success(_):
                   let cachedResponse = CachedServiceResponse(key: cacheKey, data: data)

                    cache.save(cachedResponse)
                default:
                    break
                }
            }

            do {
                return try decoder.decode(Output.self, from: data)
            } catch let error {
                throw NetworkError.failedToDecode(error.localizedDescription)
            }
        })
        
        return observable
    }
}

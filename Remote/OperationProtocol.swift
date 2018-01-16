//
//	OperationProtocol.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation
import RxSwift

/// Operation Protocol
public protocol OperationProtocol {
	associatedtype DataType
	
	/// Request
	var request: RequestProtocol? { get set }
		
	/// Execute an operation into specified service
	///
	/// - Parameters:
	///   - service: service to use
	/// - Returns: Promise
	func execute(in service: ServiceProtocol) -> Observable<DataType>
	
}

//
//  SessionDelegate.swift
//  Remote
//
//  Created by Dmitry Klimkin on 22/8/17.
//  Copyright © 2017 Dev4Jam. All rights reserved.
//

import Foundation

protocol KeychainServiceProtocol {
    func getCredentials() -> URLCredential?
    func getCertData(for local: Bool) -> Data?
    func validSessionToken() -> String?
    func validBasicAuth() -> String?
}

class SessionDelegate: NSObject, URLSessionDelegate {
    private var keychain: KeychainServiceProtocol
    
    required init(keychain service: KeychainServiceProtocol) {
        keychain = service
    }
    
    // MARK: - URL Session Delegate
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        //check for failure count, cancel authentication and inform the user
        _ = evaluate(trust: challenge.protectionSpace.serverTrust!, for: challenge.protectionSpace.host, local: true)

        //disposition and credential on the basis of challenge type
        var disposition = URLSession.AuthChallengeDisposition.performDefaultHandling

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            let credential = keychain.getCredentials()

            disposition = URLSession.AuthChallengeDisposition.useCredential
            completionHandler(disposition, credential)

        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            var credential: URLCredential? = nil
            
            if let theTrust = challenge.protectionSpace.serverTrust {
                credential = URLCredential(trust: theTrust)
                disposition = URLSession.AuthChallengeDisposition.useCredential
            }
            
            completionHandler(disposition, credential)
        }
    }
    
    private func evaluate(trust serverTrust: SecTrust, for hostname: String?, local isLocal: Bool = false) -> Bool {
        //server cert
        guard let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return false
        }
        
        //set SSL policies for domain name check
        let policies: NSMutableArray = NSMutableArray()
        
        policies.add(SecPolicyCreateSSL(true, hostname as CFString?))
        
        SecTrustSetPolicies(serverTrust, policies)
        
        //Evaluate server trust
        var result: SecTrustResultType = .invalid
        
        SecTrustEvaluate(serverTrust, &result)
        
        let isServerTrusted: Bool = (
            (result == SecTrustResultType.unspecified) ||
            (result == SecTrustResultType.proceed))
        
        //get local and server cert data
        let serverCertData: NSData = SecCertificateCopyData(serverCert)
        
        guard let localCertData = keychain.getCertData(for: isLocal) else {
            return false
        }
        
        //check trust & cert data
        guard isServerTrusted && (serverCertData.isEqual(to: localCertData)) else {
            return false
        }
        
        return true
    }
}

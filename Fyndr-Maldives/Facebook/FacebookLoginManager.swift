//
//  FacebookLoginManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 15/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin
import FBSDKCoreKit


class FacebookLoginManager {
    
    public typealias success = (_ fbProfile : SocialProfileModel?) -> Void
    public typealias failure = (_ error: Error?) -> Void
    
    func login(vc : UIViewController, onSuccess : @escaping (Bool) -> Void,  onFailure : @escaping failure) {
        
        if AccessToken.current != nil {
            onSuccess(true)
        }else{
            let loginManager = LoginManager()
            loginManager.logIn(permissions: [.publicProfile, .email], viewController: vc) { (loginResult) in
                switch loginResult {
                case .failed(let error):
                    print(error)
                    onFailure(error)
                case .cancelled:
                    print("User cancelled login.")
                    let error: Error? = NSError(domain:"User cancelled login", code:1, userInfo:nil)
                    onFailure(error)
                case .success( _, _, _):
                    print("Logged in!")
                    onSuccess(true)
                }
            }
        }
    }
    
    func getFacebookProfile(vc : UIViewController, onSuccess : @escaping success,  onFailure : @escaping failure) {
        
        if AccessToken.current != nil {
            requestFBGraphAPI(onSuccess: onSuccess, onFailure: onFailure)
        }else{
            self.login(vc: vc, onSuccess: { (success) in
                self.requestFBGraphAPI(onSuccess: onSuccess, onFailure: onFailure)
            }) { (error) in
                onFailure(error)
            }
        }
    }
    
    private func requestFBGraphAPI(onSuccess : @escaping success,  onFailure : @escaping failure)
    {
        let connection = GraphRequestConnection()
        
        connection.add(getGraphRequest(), completionHandler: { ( response , result, error) in
            print("Facebook login response -> \(String(describing: response))  result \(String(describing: result))")
            if error != nil {
                onFailure(error)
            }else{
                let fbProfile = SocialProfileModel.init(result: result as? [String : Any])
                onSuccess(fbProfile)
            }
        })
        connection.start()
    }
    
    
    
    func getGraphRequest() -> GraphRequest
    {
        _ = GraphRequestConnection()
        let graphPath = "/me"
        let parameters: [String : Any] = ["fields": "id, name,email,picture.type(large)"]
        let accessToken = AccessToken.current?.tokenString ?? ""
        
        let request = GraphRequest.init(graphPath: graphPath, parameters: parameters, tokenString: accessToken, version: .none, httpMethod: .get)
        return request
    }
}




//fileprivate struct ProfileRequest: GraphRequestProtocol {
//
//    struct Response: GraphResponseProtocol {
//        fileprivate let rawResponse: Any?
//
//        init(rawResponse: Any?) {
//            // Decode JSON from rawResponse into other properties here.
//            self.rawResponse = rawResponse
//        }
//
//        public var dictionaryValue: [String : Any]? {
//            return rawResponse as? [String : Any]
//        }
//
//        public var arrayValue: [Any]? {
//            return rawResponse as? [Any]
//        }
//
//        public var stringValue: String? {
//            return rawResponse as? String
//        }
//    }
//
//    var graphPath = "/me"
//    var parameters: [String : Any]? = ["fields": "id, name,email,gender,picture.type(large),birthday"]
//    var accessToken = AccessToken.current
//    var httpMethod: FBSDKGraphRequest = .GET
//    var apiVersion: GraphAPIVersion = .defaultVersion
//}



//
//  CheckSubscriptionRequest.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 27/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
struct CheckSubscriptionRequest {
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/checksubscription"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let deviceId = "deviceId"
        static let uniqueId = "uniqueId"
        static let language = "language"
        static let orderId = "orderId"


        
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter(uniqueId: String) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.uniqueId] = uniqueId
        param[APIKeys.language] = Util.getPhoneLang()
        
        print("   \(param)")
        return param
    }
    
    static func requestParameter(uniqueId: String, orderId: String) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.uniqueId] = uniqueId
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.orderId] = orderId
        
        
        print("   \(param)")
        return param
    }
}

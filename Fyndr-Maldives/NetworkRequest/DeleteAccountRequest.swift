//
//  DeleteAccountRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 05/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct DeleteAccountRequest {
    
    ///postlogin/deleteaccount {"uniqueId":"a3bb4e","language":"en","deviceId":"494fdd0149192677","requestSource":"APP"}
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/deleteaccount"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let deviceId = "deviceId"
        static let uniqueId = "uniqueId"
        static let language = "language"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter() -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.deviceId] = Util.deviceId()
        
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.language] = Util.getPhoneLang()
        return param
    }
}

//
//  PushRegistartionRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 07/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct PushRegistartionRequest {
    
    //curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"uniqueId" : "a53c23","deviceId":"divyamkaphone9","deviceTokenVoIP":"adagdahbdda","deviceToken":"adagdahbdda","requestSource":"APP","language":"en"}' http://172.20.12.111:8087/profileManager/postlogin/deviceToken
    

    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/deviceToken"
    }
    
    struct APIKeys {
        
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let deviceTokenVoIP = "deviceTokenVoIP"
        static let deviceToken = "deviceToken"
        static let deviceId = "deviceId"
        static let language = "language"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter(token : String) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.deviceToken] = token
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        return param
    }
}

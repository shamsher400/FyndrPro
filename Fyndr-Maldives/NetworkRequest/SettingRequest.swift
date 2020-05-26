//
//  SettingRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 05/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct SettingRequest {
    
   // curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"deviceId":"mnbvcxsa","uniqueId":"a151ca","requestSource":"APP","language":"en","isMute":true,"isVisible":true}' http://localhost:8087/profileManager/postlogin/setting
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/setting"
    }
    
    struct APIKeys {
        
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let isMute = "isMute"
        static let isVisible = "isVisible"
        static let deviceId = "deviceId"
        static let language = "language"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter(isMute : Bool, isVisible : Bool ) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.isMute] = isMute
        param[APIKeys.isVisible] = isVisible
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        return param
    }
}

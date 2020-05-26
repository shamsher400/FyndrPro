//
//  ProfileDetailRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 25/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct ProfileDetailRequest {
    
    //curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"uniqueId":"a53c23","deviceId":"divyamkaphone9","requestSource":"APP","language":"en"}' http://localhost:8087/profileManager/postlogin/profile
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/profile"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let deviceId = "deviceId"
        static let uniqueId = "uniqueId"
        static let language = "language"
        static let searchProfile = "searchProfile"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }

    static func requestParameter(uniqueId : String) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.deviceId] = Util.deviceId()
        
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.searchProfile] = uniqueId
        return param
    }
}

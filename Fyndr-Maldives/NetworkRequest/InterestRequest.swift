//
//  InterestRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct InterestRequest {
    
    //curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{ "requestSource":"APP","uniqueId":"adcc52","interestList":["1_2","2_2","3_1"],"isDelta":false,"requestSource":"APP","deviceId":"abcdefghijklmnopqrst"}' http://localhost:8087/profileManagerMaldives/postlogin/interest
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/interest"
    }
    
    struct APIKeys {
        
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let interestList = "interestList"
        static let isDelta = "isDelta"
        static let deviceId = "deviceId"
        static let language = "language"

    }
    
    struct APIValue {
        static let requestSource = "APP"
        static let isDelta = false
    }
    
    static func
        requestParameter(interestList : [String]?) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.isDelta] = APIValue.isDelta
        param[APIKeys.interestList] = interestList
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        return param
    }
}

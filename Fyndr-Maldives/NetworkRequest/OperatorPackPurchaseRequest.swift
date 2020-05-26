//
//  OperatorPackPurchaseRequest.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 03/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct OperatorPackPurchaseRequest {
    
    //curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -H "devicetype: ANDROID" -X POST -d '{"uniqueId":"afabe3","deviceId":"ADEED45D-36AD-4E19-9CC0-9F2725509940","language":"en","requestSource":"APP","packId":"pack3"}' http://172.20.12.111:8087/profileManager/postlogin/subscribe
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/subscribe"
    }
    
    struct APIKeys {
        
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let interestList = "interestList"
        static let deviceId = "deviceId"
        static let language = "language"
        static let packId = "packId"
        
    }
    
    struct APIValue {
        static let requestSource = "APP"
        static let isDelta = false
    }
    
    static func
        requestParameter(packId: String) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.packId] = packId
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        return param
    }
}

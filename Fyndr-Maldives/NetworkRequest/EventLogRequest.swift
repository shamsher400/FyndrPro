//
//  EventLogRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct EventLogRequest {
    
   // curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"uniqueId":"a3bb4e","deviceId":"eb25fd39d2ca8300","language":"en","requestSource":"APP"}' http://172.20.12.111:8087/profileManager/postlogin/event

    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/prelogin/event"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let deviceId = "deviceId"
        static let uniqueId = "uniqueId"
        static let language = "language"
        static let event = "events"
    }

    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter(events : [Event]) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.deviceId] = Util.deviceId()
        
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.event]  = events.map({$0.dictionaryRepresentation()})
        return param
    }
}

//
//  UnnsubscribePackRequst.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 12/11/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct UnsubscribePackRequst {
    
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/unsubscribe"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let deviceId = "deviceId"
        static let language = "language"
    }
    
    struct APIValue {
        static let requestSource = "APP"
        static let isDelta = false
    }
    
    static func
        requestParameter() -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        return param
    }
    
}

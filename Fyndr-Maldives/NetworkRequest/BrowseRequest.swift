//
//  BrowseRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct BrowseRequest {
    
    //curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"uniqueId":"adcc52","searchType":"DEFAULT","language":"en","deviceId":"abcdefghijklmnopqrst","requestSource":"APP"}' http://localhost:8087/profileManagerMaldives/postlogin/browse
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/browse"
    }
    
    struct APIKeys {

        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let searchType = "searchType"
        static let language = "language"
        static let deviceId = "deviceId"
        static let isFirstRequest = "isFirst"
        static let searchOn = "searchOn"
    }
    
    struct APIValue {
        static let requestSource = "APP"
        static let isDelta = false
        static let searchType = "SPECIFIC"
    }
    
    static func requestParameter(searchType : String,isFirst : Bool) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        if searchType != SEARCH_TYPE_DEFAULT
        {
            param[APIKeys.searchType] = APIValue.searchType
            param[APIKeys.searchOn] = searchType

        }else{
            param[APIKeys.searchType] = searchType
        }
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.isFirstRequest] = isFirst

        return param
    }
}

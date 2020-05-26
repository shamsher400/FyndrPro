//
//  BlackListRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

enum BlackListAction : String {
    case ADD = "ADD"
    case DELETE = "DELETE"
    case GET = "GET"
}

struct BlackListRequest {
    
    /*
     a. Add blacklist
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"fromUniqueId":"a11aaa","action":"ADD","uniqueId":"a11aaa","deviceId":"babakaphone4","toUniqueId":"a31424"}' http://localhost:8087/profileManagerMaldives/postlogin/blacklist
     
     b. Delete blacklist
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"fromUniqueId":"a11aaa","action":"DELETE","uniqueId":"a11aaa","deviceId":"babakaphone4","toUniqueId":"a31424"}' http://localhost:8087/profileManagerMaldives/postlogin/blacklist
     
     
     
     b. Get blacklist
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"fromUniqueId":"a11aaa","action":"GET","uniqueId":"a11aaa","deviceId":"babakaphone4", "pageIndex":"0","pageSize":5}' http://localhost:8087/profileManagerMaldives/postlogin/blacklist
     */
    
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/blacklist"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let deviceId = "deviceId"
        static let uniqueId = "uniqueId"
        static let toUniqueId = "toUniqueId"
        static let action = "action"
        static let pageIndex = "pageIndex"
        static let pageSize = "pageSize"
        static let fromUniqueId = "fromUniqueId"
        static let language = "language"
        static let timeStamp = "timeStamp"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }

    static func requestParameter(blockListIds : [BlockIds]?, action : BlackListAction , pageIndex : Int = 0, pageSize : Int = 0 ) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()

        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
            param[APIKeys.fromUniqueId] = userId
        }
        
        switch action {
        case .ADD:
            param[APIKeys.action] = BlackListAction.ADD.rawValue
            
        case .DELETE:
            param[APIKeys.action] = BlackListAction.DELETE.rawValue
            
        case .GET:
            param[APIKeys.action] = BlackListAction.GET.rawValue
            param[APIKeys.pageIndex] = pageIndex
            param[APIKeys.pageSize] = pageSize
        }
//        if let blockListIds = blockListIds {
//            param[APIKeys.toUniqueId] = blockListIds.first
//        }
//        param[APIKeys.toUniqueId] = blockListIds
        
        var toUniqueIds = [[String : Any]]()
        
        if let blockListIds = blockListIds {
            for blockListId in blockListIds
            {
                var toUniqueId = [String : Any]()
                toUniqueId[APIKeys.uniqueId] = blockListId.uniqueId
                toUniqueId[APIKeys.timeStamp] = blockListId.timeStamp
                toUniqueIds.append(toUniqueId)
            }
        }
        param[APIKeys.toUniqueId] = toUniqueIds
        
        return param
    }
}


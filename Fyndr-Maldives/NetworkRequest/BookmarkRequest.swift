//
//  BookmarkRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

enum BookmarkAction : String {
    case ADD = "ADD"
    case DELETE = "DELETE"
    case GET = "GET"
}

struct BookmarkRequest {
    
    /*
     a. Add bookmark
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"fromUniqueId":"a11aaa","action":"ADD","uniqueId":"a11aaa","deviceId":"babakaphone4","toUniqueId":"a31424"}' http://localhost:8087/profileManagerMaldives/postlogin/bookmark
     
     b. Delete bookmark
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"fromUniqueId":"a11aaa","action":"DELETE","uniqueId":"a11aaa","deviceId":"babakaphone4","toUniqueId":"a31424"}' http://localhost:8087/profileManagerMaldives/postlogin/bookmark
     
     b. Get bookmarks
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"fromUniqueId":"a11aaa","action":"GET","uniqueId":"a11aaa","deviceId":"babakaphone4", "pageIndex":"0","pageSize":5}' http://localhost:8087/profileManagerMaldives/postlogin/bookmark
     */
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/bookmark"
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
    
    static func requestParameter(bookmarkIds : [BookmarkIds]?, action : BookmarkAction , pageIndex : Int = 0, pageSize : Int = 0 ) -> [String: Any]
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
            param[APIKeys.action] = BookmarkAction.ADD.rawValue
            
        case .DELETE:
            param[APIKeys.action] = BookmarkAction.DELETE.rawValue
            
        case .GET:
            param[APIKeys.action] = BookmarkAction.GET.rawValue
            param[APIKeys.pageIndex] = pageIndex
            param[APIKeys.pageSize] = pageSize
        }

        var toUniqueIds = [[String : Any]]()
        
        if let bookmarkIds = bookmarkIds {
            for bookmarkId in bookmarkIds
            {
                var toUniqueId = [String : Any]()
                toUniqueId[APIKeys.uniqueId] = bookmarkId.uniqueId
                toUniqueId[APIKeys.timeStamp] = bookmarkId.timeStamp
                toUniqueIds.append(toUniqueId)
            }
        }
        param[APIKeys.toUniqueId] = toUniqueIds
        return param
    }
}

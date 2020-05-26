//
//  ConnectionRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 24/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

enum ConnectionOperation : String {
    case getConnectionList = "getConnectionList"
    case getRecentList = "getRecentList"
    case add = "add"
}

struct ConnectionRequest {
    
    //curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"uniqueId":"a3bb4e","language":"en","deviceId":"494fdd0149192677","requestSource":"APP","bParty":"a151ca","type":"chat","operation":"getConnectionList"/"getRecentList"/"add","pageSize":5,"pageNumber":0}' http://172.20.12.111:8087/profileManager/postlogin/connection
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/connection"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let deviceId = "deviceId"
        static let uniqueId = "uniqueId"
        static let bParty = "bParty"
        static let operation = "operation"
        static let pageNumber = "pageIndex"
        static let pageSize = "pageSize"
        static let language = "language"
        static let type = "type"
    }
    
    struct APIValue {
        static let requestSource = "APP"
        static let type = "chat"
    }
    
    static func requestParameter(bParty : String, operation : ConnectionOperation , pageNumber : Int = 0, pageSize : Int = 500 ) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.bParty] = bParty
        param[APIKeys.type] = APIValue.type

        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        
        switch operation {
        case .add:
            param[APIKeys.operation] = ConnectionOperation.add.rawValue
            
        case .getConnectionList:
            param[APIKeys.operation] = ConnectionOperation.getConnectionList.rawValue
            param[APIKeys.pageNumber] = pageNumber
            param[APIKeys.pageSize] = pageSize
            
        case .getRecentList:
            param[APIKeys.operation] = ConnectionOperation.getRecentList.rawValue
            param[APIKeys.pageNumber] = pageNumber
            param[APIKeys.pageSize] = pageSize
        }
        print("requestData \(param)")
        return param
    }
}

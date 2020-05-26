//
//  ResourceRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

enum ResourceType : String {
    case image = "image"
    case video = "video"
}

struct ResourceRequest {
    
    /*
     1. create resource
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"type":"image","size":5,"name":"test.png","deviceId":"abcdefghijklmnopqrstuvw","uniqueId":"adcc52"}' http://localhost:8087/profileManagerMaldives/postlogin/avi
     
     2. upload resource
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "password: fE52aEeZahmpLwbCi8fMbNCD1zs=" -F 'request={"deviceId":"abcdefghijklmnopqrstuvw"}' -F file=@test.png http://localhost:8087/profileManagerMaldives/postlogin/avi/adcc52/i155833670342798
     
     3. get resource
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" 'http://localhost:8087/profileManager/profileManagerMaldives/avi/adcc52/i155833670342798?deviceId=abcdefghijklmnopqrstuvw'
     
     4. delete resource
     curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X DELETE 'http://localhost:8087/profileManager/postlogin/avi/adcc52/i155833670342798?deviceId=abcdefghijklmnopqrstuvw'
     */
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/avi"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let deviceId = "deviceId"
        static let uniqueId = "uniqueId"
        static let type = "type"
        static let name = "name"
        static let size = "size"
        static let password = "password"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    // size in kb
    static func requestParameter(type : ResourceType, name : String , size : Int) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.type] = type.rawValue
        param[APIKeys.size] = size
        param[APIKeys.name] = name
        param[APIKeys.deviceId] = Util.deviceId()
        
        return param
    }
    
    static func uploadResourceRequestParameter(password : String) -> [String: String]
    {
        var param = [String: String]()
        param[APIKeys.password] = password
        param[APIKeys.deviceId] = Util.deviceId()
        print("API upload request param : \(param)")
        return param
    }
    
    static func deleteImageRequestParameter() -> [String: String]
    {
        var param = [String: String]()
        param[APIKeys.password] = Util.deviceId()
        return param
    }
    
    static func getImageRequestParameter() -> [String: String]
    {
        var param = [String: String]()
        param[APIKeys.password] = Util.deviceId()
        return param
    }
    
    static func deleteVideoRequestParameter() -> [String: String]
    {
        var param = [String: String]()
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.requestSource] = APIValue.requestSource
        return param
    }
}

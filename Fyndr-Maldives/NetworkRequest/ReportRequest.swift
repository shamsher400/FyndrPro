//
//  ReportRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 05/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct ReportRequest {
    
 //   1. Report reasons API-
//  curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"uniqueId":"acba11","deviceId":"qwertyuiiop","requestSource":"APP","language":"en"}' http://localhost:8087/profileManager/postlogin/reportreasons
    
  //  {"reasons":["Made me uncomfortable","Inappropriate content","Stolen photo"],"status":"SUCCESS","subStatus":"SUCCESS","reason":"Reasons in the given language"}
    
    
 //   2.  Report Abuse API-
   // curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -X POST -d '{"reportedId":"abcd123","deviceId":"mnbvcxsa","uniqueId":"a151ca","requestSource":"APP","reason":"Made me uncomfortable", "comments":"this guy had an abusive profile with lots of nudity. Please block him"}' http://localhost:8087/profileManager/postlogin/report
    
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/report"
        static let APIPathGetReasons = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/reportreasons"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let reportedId = "reportedId"
        static let language = "language"
        static let deviceId = "deviceId"
        static let comments = "comments"
        static let reason = "reason"
        static let reasonId = "reasonId"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter(reportedId : String, reasonId : String, reason : String, comments : String) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.reportedId] = reportedId
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.comments] = comments
        param[APIKeys.reason] = reason
        param[APIKeys.reasonId] = reasonId
        return param
    }
    
    static func requestParameterReportReasons() -> [String: Any]
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

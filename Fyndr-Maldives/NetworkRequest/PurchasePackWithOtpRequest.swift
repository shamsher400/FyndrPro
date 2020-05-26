//
//  PurchasepackWithOtpRequest.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 11/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
struct PurchasePackWithOtpRequest {
    
    //curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZGNjNTIifQ.qvkPbrhkfBUdTEQ9V8eV8lvrlDlcEqoxkfoBMDyw7zWurHAPdZ8Fb0iuYKG9xruS6cfBL_Qc96ZLIpOkEbNn5w" -H "Content-type: application/json" -H "DeviceType: IOS" -X POST -d '{"requestSource":"APP","uniqueId":"aa5453","deviceId":"BAC9ACD5-9094-46C2-AF97-D35C01310FD1","language":"en"}' http://localhost:8087/profileManager/postlogin/packs
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/verifysub"
    }
    
    struct APIKeys {
        
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let interestList = "interestList"
        static let deviceId = "deviceId"
        static let language = "language"
        static let receipt = "receipt"
        static let orderId = "orderId"
        static let otp = "otp"

        
    }
    
    struct APIValue {
        static let requestSource = "APP"
        static let isDelta = false
    }
    
    static func requestParameter(orderId: String, otp: String) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.orderId] = orderId
        param[APIKeys.otp] = otp
        return param
    }
}

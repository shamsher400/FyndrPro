//
//  SendOtpRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct SendOtpRequest {
    
    //curl -H "Authorization: Bearer badiyaTokenStringjoKibohotlambihai" -H "Content-type: application/json" -X POST -d '{"countryCallingCode":"91","countryName":"Bharat","deviceId":"abcdefghijklmnopqrstuvw","deviceName":"babakaphone6","deviceType":"ANDROID","number":"919891006461"}' http://localhost:8087/profileManager/prelogin/sendotp
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/prelogin/sendotp"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let countryCallingCode = "countryCallingCode"
        static let countryName = "countryName"
        static let deviceId = "deviceId"
        static let deviceName = "deviceName"
        static let deviceType = "deviceType"
        static let number = "number"
        static let language = "language"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter(number : String,callingCode : String) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.countryCallingCode] = callingCode
        param[APIKeys.countryName] = Util.getCountryIsoCode()
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.deviceName] = Util.getDeviceInfo()
        param[APIKeys.deviceType] = Util.getDeviceType()
        param[APIKeys.number] = number
        param[APIKeys.language] = Util.getPhoneLang()
        return param
    }
}

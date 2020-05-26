//
//  RegistrationRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct RegistrationRequest {
    
    //curl -H "Authorization: Bearer badiyaTokenStringjoKibohotlambihai" -H "Content-type: application/json" -X POST -d '{"deviceId":"abcdefghijklmnopqrstuvw","number":"919891006461","registrationMethod":"otp","registrationMode":"APP","otp":"877001"}' http://localhost:8087/profileManagerMaldives/prelogin/register
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/prelogin/register"
    }
    
    struct APIKeys {
        static let deviceId = "deviceId"
        static let number = "number"
        static let registrationMethod = "registrationMethod"
        static let registrationMode = "registrationMode"
        static let otp = "otp"
        static let language = "language"
        static let deviceType = "deviceType"
        static let fbId = "fbid"
        static let googleId = "googleid"
        static let appleId = "appleid"
        static let email = "email"


    }
    
    struct APIValue {
        static let registrationMode = "APP"
    }
    
    static func requestParameter(number : String,otp : String, registrationMethod : RegistrationMethods) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.number] = number
        param[APIKeys.registrationMethod] = registrationMethod.rawValue
        if registrationMethod == .OTP
        {
            param[APIKeys.otp] = otp
        }else if registrationMethod == .GOOGLE {
            param[APIKeys.email] = otp
        }
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.deviceType] = Util.getDeviceType()
        param[APIKeys.registrationMode] = APIValue.registrationMode
        return param
    }
    
    static func requestParameter(registrationMethod : RegistrationMethods, socialProfile: SocialProfileModel) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.registrationMethod] = registrationMethod.rawValue
        if registrationMethod == .GOOGLE {
            param[APIKeys.email] = socialProfile.email
            param[APIKeys.googleId] = socialProfile.userId
        }else if registrationMethod == .FB {
            param[APIKeys.email] = socialProfile.email
            param[APIKeys.fbId] = socialProfile.userId
        }else if registrationMethod == .APPLE {
            param[APIKeys.email] = socialProfile.email
            param[APIKeys.appleId] = socialProfile.userId
        }
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.deviceType] = Util.getDeviceType()
        param[APIKeys.registrationMode] = APIValue.registrationMode
        return param
    }
}

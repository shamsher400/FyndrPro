//
//  CreateProfileRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct CreateProfileRequest {
    
    //curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhYjRhNGYifQ.avXJqvRIxiziqaeL1jOmqWTGcRTt35Fv2JTi5QT7ewIGKMtn7MTy0tvHrQ_eDMvExEUywmtE5aaUq1XrWV8hLwloda" -H "Content-type: application/json" -X POST -d '{"dob":"1992-12-28", "requestSource":"APP","uniqueId":"ab4a4f","city":"Gurgram","gender":"M","name":"piyush","deviceId":"abcdefghijklmnopqrstuvw"}' http://localhost:8087/profileManagerMaldives/postlogin/createprofile
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/createprofile"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let dob = "dob"
        static let city = "city"
        static let gender = "gender"
        static let name = "name"
        static let deviceId = "deviceId"
        static let language = "language"
        static let about = "bio"

        
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter(profile : Profile) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.uniqueId] = profile.uniqueId
        param[APIKeys.dob] = profile.dob
        param[APIKeys.city] = profile.city?.id
        param[APIKeys.gender] = profile.gender
        if let encodeName = profile.name?.stringToUTF8Byte() {
            param[APIKeys.name] = encodeName

        }
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.about] = (profile.about ?? "").stringToUTF8Byte()

        return param
    }
}

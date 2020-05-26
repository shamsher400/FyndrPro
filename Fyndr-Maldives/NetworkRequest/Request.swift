//
//  Request.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import Kingfisher

struct Request {
    struct RequestURL {
        static let pubilcIP = "https://mdv.fyndrapp.com:8088/" // Public IP
        static let localIP = "https://mdv.fyndrapp.com:8088/" // Local IP
//        static let awsIP = "https://13.126.1.136:8087/" // AWS IP
        static let awsIP = "https://mdv.fyndrapp.com:8088/" // AWS IP
        static let baseUrl = AWS_IP ? awsIP : PUBLIC_IP ? pubilcIP : localIP
    }
    
    struct APIKeys {
        static let countryISOCode = "countryISOCode"
        static let defaultLanguage = "defaultLanguage"
        static let authorizationBearer = "Authorization"
        static let contentType = "Content-Type"
        static let deviceType = "deviceType"
        static let DeviceInfo = "DeviceInfo"
        static let DeviceId = "DeviceId"

    }
     
    struct APIValues {
        static let authorizationBearer = "Bearer badiyaTokenStringjoKibohotlambihai"
//        static let authorizationBearer = "J0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9"
        static let contentType = "application/json"
    }
    
    static func requestHeaderParameter() -> [String: String]
    {
        var header = [String: String]()
        header[APIKeys.countryISOCode] = Util.getUserCountryCode().removePlus()
        header[APIKeys.defaultLanguage] = Util.getPhoneLang()
        header[APIKeys.contentType] = APIValues.contentType
        header[APIKeys.deviceType] = Util.getDeviceType()
        header[APIKeys.DeviceInfo] = Util.getDeviceInfo()
        header[APIKeys.DeviceId] = Util.deviceId()

        if let authToken = UserDefaults.standard.object(forKey: USER_DEFAULTS.AUTH_TOKEN)
        {
            header[APIKeys.authorizationBearer] = "Bearer \(authToken)"
        }else {
            header[APIKeys.authorizationBearer] = APIValues.authorizationBearer
        }
        print("header : \(header)")
        return header
    }
    
    
    static func resourceHeader() -> AnyModifier
    {
        let modifier = AnyModifier { request in
            var r = request
            if let authToken = UserDefaults.standard.object(forKey: USER_DEFAULTS.AUTH_TOKEN)
            {
                r.setValue("Bearer \(authToken)", forHTTPHeaderField: APIKeys.authorizationBearer)
            }else {
                r.setValue(APIValues.authorizationBearer, forHTTPHeaderField: APIKeys.authorizationBearer)
            }
            return r
        }
        return modifier
    }
}

//
//  ConfigurationRequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct ConfigurationRequest {

    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/prelogin/configuration"
    }
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let countryISOCode = "countryISOCode"
        static let primarymnc = "primarymnc"
        static let primarymcc = "primarymcc"
        static let secondarymnc = "secondarymnc"
        static let secondarymcc = "secondarymcc"
        static let language = "language"
        static let type = "type"
        static let appVersion = "appVersion"
        static let uniqueId = "uniqueId"
    }
    
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter(configurationType : ConfigurationType) -> [String: Any]
    {
        var param = [String: Any]()
        // param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.countryISOCode] = Util.getUserCountryCode().removePlus()
        param[APIKeys.primarymnc] = Util.getMncMcc().0
        param[APIKeys.primarymcc] = Util.getMncMcc().1
        param[APIKeys.secondarymnc] = ""
        param[APIKeys.secondarymcc] = ""
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.type] = configurationType.rawValue
        
        if configurationType == ConfigurationType.basic {
            if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
            {
                param[APIKeys.appVersion] = Util.getAppVersion()
                param[APIKeys.uniqueId] = userId
            }
        }
        return param
    }
    
    static func requestParameter(configurationType : ConfigurationType, languageCode: String) -> [String: Any]
    {
        var param = [String: Any]()
        // param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.countryISOCode] = Util.getUserCountryCode().removePlus()
        param[APIKeys.primarymnc] = Util.getMncMcc().0
        param[APIKeys.primarymcc] = Util.getMncMcc().1
        param[APIKeys.secondarymnc] = ""
        param[APIKeys.secondarymcc] = ""
        param[APIKeys.language] = languageCode
        param[APIKeys.type] = configurationType.rawValue
        
        if configurationType == ConfigurationType.basic {
            if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
            {
                param[APIKeys.appVersion] = Util.getAppVersion()
                param[APIKeys.uniqueId] = userId
            }
        }
        return param
    }
}

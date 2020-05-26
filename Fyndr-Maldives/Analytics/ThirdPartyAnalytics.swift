//
//  ThirdPartyAnaytics.swift
//  Fyndr
//
//  Created by Shamsher Singh on 12/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import Firebase

class ThirdPartyAnalytics: AnalyticsEngine {
    
    struct APIKeys {
        static let uniqueId = "fromUid"
        static let deviceId = "deviceId"
    }
    
    func sendAnalyticsEvent(name: String, parameter: [String : Any]) {
        
        var editParameater = parameter
        editParameater[APIKeys.deviceId] = Util.deviceId()
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            editParameater[APIKeys.uniqueId] = userId
        }
        
        print("TPEevenLog - : \(name) : \(editParameater)")
        Analytics.logEvent(name, parameters: editParameater)
    }
    
}

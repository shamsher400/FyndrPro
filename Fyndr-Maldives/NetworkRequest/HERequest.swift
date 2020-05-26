//
//  HERequest.swift
//  Fyndr
//
//  Created by BlackNGreen on 29/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
struct HERequest {
    
    struct APIKeys {
        static let requestSource = "requestSource"
        static let deviceId = "deviceId"
        static let deviceType = "deviceType"
    }
    
    struct APIValue {
        static let requestSource = "APP"
    }
    
    static func requestParameter() -> [String: String]
    {
        var param = [String: String]()
        param[APIKeys.requestSource] = APIValue.requestSource
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.deviceType] = Util.getDeviceType()
        return param
    }
}

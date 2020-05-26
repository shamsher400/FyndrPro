//
//  SendOtpResponse.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 16/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON


public final class SendOtpResponse {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let isLogout = "isLogout"
        static let noOtp = "noOtp"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var isLogout: Bool = false
    public var noOtp: Bool = false
    
    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        isLogout = json[SerializationKeys.isLogout].boolValue
        if let isOptUser = json[SerializationKeys.noOtp].bool {
            noOtp = isOptUser
        }
    }
    
    
}

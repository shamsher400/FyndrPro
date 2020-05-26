//
//  GetProfileResponse.swift
//  Fyndr
//
//  Created by Shamsher Singh on 09/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct GetProfileResponse : Codable {
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let isProfile = "isProfile"
        static let isInterest = "isInterest"
        static let token = "token"
        static let uniqueId = "uniqueId"
        static let jabberId = "jabberId"
        static let password = "password"
        static var profile = "profile"
        static let isCall = "isCall"
        static let isChat = "isChat"
        static let callType = "callType"
        
        static var chatConf = "chatConf"
        static var sipConf = "sipConf"
        
        static var isDeleted = "isDeleted"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    
    public var isProfile = false
    public var isInterest = false
    
    public var token: String?
    public var uniqueId: String?
    public var jabberId: String?
    public var password: String?
    
    public var isCall = false
    public var isChat = false
    public var callType: String?
    public var isDeleted: Bool?

    
    public var profile: Profile?
    public var chatConfiguration: ChatConfiguration?
    public var sipConfiguration: SipConfiguration?
    
    public init(json: JSON) {
        
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        
        isProfile = json[SerializationKeys.isProfile].boolValue
        isInterest = json[SerializationKeys.isInterest].boolValue
        
        token = json[SerializationKeys.token].string
        uniqueId = json[SerializationKeys.uniqueId].string
        jabberId = json[SerializationKeys.jabberId].string
        password = json[SerializationKeys.password].string
        profile = Profile.init(json: json[SerializationKeys.profile])
        
        isCall = json[SerializationKeys.isCall].boolValue
        isChat = json[SerializationKeys.isChat].boolValue
        callType = json[SerializationKeys.callType].string
        
        chatConfiguration = ChatConfiguration.init(json: json[SerializationKeys.chatConf])
        sipConfiguration = SipConfiguration.init(json: json[SerializationKeys.sipConf])
        
        if let isDeleted = json[SerializationKeys.isDeleted].bool {
            self.isDeleted = isDeleted
        }
    }
}

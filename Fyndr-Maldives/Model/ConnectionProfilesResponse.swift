//
//  ConnectionProfilesResponse.swift
//  Fyndr
//
//  Created by Shamsher Singh on 26/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON


struct ConnectionProfilesResponse : Codable {
    
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static var profileList = "connectedProfiles"
        static let profileConnections = "connections"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var profileList: [Profile]?
    public var profileConnectionsList: [ProfileConnections]?
    
    public init(json: JSON) {
        
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        if let profileConnections = json[SerializationKeys.profileConnections].array {
            self.profileConnectionsList = profileConnections.map { ProfileConnections.init(json: $0)}
        }
        if let profileItem = json[SerializationKeys.profileList].array {
            profileList = profileItem.map { Profile.init(json: $0)}
        }
    }
}

struct ProfileConnections : Codable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    struct SerializationKeys {
        static let bParty = "bParty"
        static let timeStamp = "timestamp"
        static let id = "id"
    }
    
    public var bParty: String?
    public var timeStamp: Int64?
    public var id: String?
    
    
    public init(json: JSON) {
        bParty = json[SerializationKeys.bParty].string
        timeStamp = json[SerializationKeys.timeStamp].int64
        id = json[SerializationKeys.id].string
    }
    
    init(bParty : String , timeStamp : Int64?) {
        self.bParty = bParty
        self.timeStamp = timeStamp ?? Date().millisecondsSince1970
    }
    
    init(bParty : String?) {
        self.bParty = bParty
        self.timeStamp = Date().millisecondsSince1970
    }
}

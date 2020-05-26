//
//  RecentProfilesResponse.swift
//  Fyndr
//
//  Created by Shamsher Singh on 26/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON


struct RecentProfilesResponse : Codable {
    
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static var profileList = "recentProfiles"
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
        if let profileCon = json[SerializationKeys.profileConnections].array {
            profileConnectionsList = profileCon.map { ProfileConnections.init(json: $0)}
        }
        if let profileItem = json[SerializationKeys.profileList].array {
            profileList = profileItem.map { Profile.init(json: $0)}
            
        }
    }
        
}

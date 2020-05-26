//
//  BrowserProfilesResponse.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BrowserProfilesResponse : Codable {
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static var profileList = "profileList"
        static var categoryList = "category"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var profileList: [Profile]?
    public var categoryList: [Interest]?

    public init(json: JSON) {
        
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        if let profileItem = json[SerializationKeys.profileList].array {
            profileList = profileItem.map { Profile.init(json: $0)}
        }
        if let categoryListItem = json[SerializationKeys.categoryList].array {
            categoryList = categoryListItem.map { Interest.init(json: $0)}
        }
    }
}

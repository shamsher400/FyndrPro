//
//  BlockListResponse.swift
//  Fyndr
//
//  Created by BlackNGreen on 03/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BlockListResponse : Codable {
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let count = "count"
        static let blackListedProfiles = "blackListedProfiles"
        static let blackList = "blackList"
    }
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var count : Int?
    public var profileList: [Profile]?
    public var blockList: [BlockIds]?

    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        count = json[SerializationKeys.count].int
        if let blockProfileList = json[SerializationKeys.blackListedProfiles].array { profileList = blockProfileList.map { Profile.init(json: $0) } }
        if let blackList = json[SerializationKeys.blackList].array { blockList = blackList.map { BlockIds.init(json: $0) } }
    }    
}

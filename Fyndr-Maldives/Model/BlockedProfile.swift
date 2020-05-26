//
//  BlockedProfile.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BlockedProfile {
    
    // MARK: Properties
    public var avatarUrl: String?
    public var createdDate: Int64 = 0
    public var name: String?
    public var requestStatus: Int16 = Int16(SyncStatus.SUCCESS.rawValue)
    public var status: Int16 = 1
    public var uniqueId: String?
    
    // status => 1:Blocked 0:Unblocked
}

struct BlockIds : Codable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    struct SerializationKeys {
        static let uniqueId = "blackListedId"
        static let timeStamp = "timeStamp"
    }
    
    public var uniqueId: String?
    public var timeStamp: Int64?
    
    public init(json: JSON) {
        uniqueId = json[SerializationKeys.uniqueId].string
        timeStamp = json[SerializationKeys.timeStamp].int64
    }
    
    init(uniqueId : String , timeStamp : Int64?) {
        self.uniqueId = uniqueId
        self.timeStamp = timeStamp ?? Date().millisecondsSince1970
    }
    
    init(uniqueId : String?) {
        self.uniqueId = uniqueId
        self.timeStamp = Date().millisecondsSince1970
    }
}

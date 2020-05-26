//
//  BookmarkResponse.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BookmarkResponse : Codable {

    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let count = "count"
        static let bookMarkedProfiles = "bookMarkedProfiles"
        static let bookMarks = "bookMarks"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var count : Int?
    public var profileList: [Profile]?
    public var bookmarkList: [BookmarkIds]?

    
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        count = json[SerializationKeys.count].int
       if let bookMarkedProfileList = json[SerializationKeys.bookMarkedProfiles].array { profileList = bookMarkedProfileList.map { Profile.init(json: $0) } }
        
        if let timestampAndIdList = json[SerializationKeys.bookMarks].array { bookmarkList = timestampAndIdList.map { BookmarkIds.init(json: $0) } }
    }
}

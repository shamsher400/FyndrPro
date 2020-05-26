//
//  ChatModel.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ConnectionStatus : Int {
    case new = 0
    case connected = 1
}

//enum ReadStatus : Int {
//    case unread = 0
//    case read = 1
//}

struct ChatHistory {

    public var avatarUrl : String?
    public var contactNumber : String?
    public var createdDate : Int64 = 0
    public var lastMessage : String?
    public var name : String?
    // B party unique id
    public var uniqueId : String?
    public var connectionStatus : Int = ConnectionStatus.new.rawValue
    //public var readStatus : Int = 0
    public var unReadMessageCount : Int = 0
    
}

//
//  Chat.swift
//  Fyndr
//
//  Created by BlackNGreen on 01/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

enum ChatType : String {
    case chat = "chat"
    case missedCall = "missedCall"
    case outgoingCall = "outgoingCall"
    case incommingCall = "incommingCall"
}

enum MessageSentStatus : Int {
    case peding = 0
    case sent = 1
    case failed = 2
}

enum MessageReadStatus : Int {
    case read = 1
    case unread = 0
}

enum MessageSource : Int {
    case sent = 1
    case receive = 0
}

struct ChatModel : Codable {
    
    // MARK: Properties
    public var chatId: String?
    public var uniqueId: String?
    public var avatarUrl: String?
    public var messageSource = MessageSource.sent.rawValue
    public var type: String?
    public var message: String?
    public var messageDate: Int64 = 0
    public var media: Data?
    public var messageSentStatus : Int = MessageSentStatus.peding.rawValue
    public var messageReadStatus : Int = MessageReadStatus.read.rawValue

   // public var attributes: [String:String]?
    //public var isSuccessReceipt: Bool = false
}


//extension ChatModel: Dated {
//    var date: Date {
//        return messageDate ?? Date()
//    }
//}

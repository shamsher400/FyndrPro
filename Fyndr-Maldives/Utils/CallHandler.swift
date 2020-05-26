//
//  CallHandler.swift
//  Fyndr
//
//  Created by BlackNGreen on 05/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

class CallHandler {

    class func initiateCall(profile : Profile?, chatHistory : ChatHistory?) -> ChatModel?
    {
        var chatHistory = chatHistory
        
        if profile == nil && chatHistory == nil
        {
            print("CallHandler Comming from invalid source view controller")
            return nil
        }
        if chatHistory == nil
        {
            chatHistory = ChatHistory()
            
            if let profile = profile, let uniqueId = profile.uniqueId
            {
                if let chatHistoryObj = DatabaseManager.shared.getChatHistory(for: uniqueId)
                {
                    chatHistory = chatHistoryObj
                }
                chatHistory?.avatarUrl = profile.imageList?.first?.url
                chatHistory?.contactNumber = profile.contactNumber
                chatHistory?.name = profile.name
                chatHistory?.uniqueId = profile.uniqueId
            }
        }
        
        print("CallHandler Call to : \(String(describing: chatHistory?.contactNumber))")
        guard let contactNumber = chatHistory?.contactNumber else {
            return nil
        }
        contactNumber.makeCall()


        chatHistory?.lastMessage = NSLocalizedString("M_OUTGOING_CALL", comment: "")
        chatHistory?.createdDate = Date().millisecondsSince1970
        chatHistory?.connectionStatus = ConnectionStatus.connected.rawValue
        DatabaseManager.shared.saveUpdateChatHistory(chatHistory: chatHistory!)
        
        let chatId = UUID().uuidString
        var chat = ChatModel.init()
        chat.chatId = chatId
        chat.uniqueId = chatHistory?.uniqueId
        chat.messageSource = MessageSource.sent.rawValue
        chat.type = ChatType.outgoingCall.rawValue
        chat.messageDate = chatHistory?.createdDate ?? 0
        chat.message = chatHistory?.lastMessage
        DatabaseManager.shared.saveUpdateChat(chat: chat)
        
        callAttemptAnalytics(cid: contactNumber, profileId: chatHistory?.uniqueId ?? "" )
        return chat
        
    }
    
}
extension CallHandler {
    class func callAttemptAnalytics(cid: String, profileId: String){
        TPAnalytics.log(.callAttempted(uniqueid: profileId))
        AppAnalytics.log(.callAttemptedWithCid(cid: cid, uniqueid: profileId))
    }
}

//
//  ChatManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 20/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import XMPPFramework
import MessageKit

enum XMPPError: Error {
    case wrongUserJID
}

class Config {
    var hostName: String? = nil
    var userJID: XMPPJID? = nil
    var hostPort: UInt16? = nil
    var password: String? = nil
}

enum XMPPConnectionSatus : String{
    case ideal
    case initialized
    case connecting
    case connected
    case ready
    case failed
    case authenticate
}

protocol ChatManagerDelegate {
    func didReceiveMessage(chat : ChatModel, sender : Sender)
    func didFailedMessage(mxppMessage :String, error : Error)
    func didSendMessage()
}


class ChatManager : NSObject {
    
    static let share = ChatManager()
    var connectionSatus : XMPPConnectionSatus = .ideal
    fileprivate var delegate : ChatManagerDelegate?
    
    fileprivate var xmppStream: XMPPStream?
    fileprivate let xmppRosterStorage = XMPPRosterCoreDataStorage()
    fileprivate var xmppRoster: XMPPRoster?
    
    fileprivate var hostName: String?
    fileprivate var userJID: XMPPJID?
    fileprivate var hostPort: UInt16?
    fileprivate var password: String?
    
    var isReady: Bool = false
    
    
    private override init() {
        super.init()
        guard let profile = Util.getProfile(), let chatConfiguration = Util.getChatConfiguration() else {
            return
        }
        self.configure(profile: profile, chatConfiguration: chatConfiguration)
    }
    
    func configure(profile : Profile, chatConfiguration : ChatConfiguration)
    {
        guard let hostIp = chatConfiguration.hostIp, let jabberId = profile.jabberId, let password = profile.password else {
            print("Chat : Inavlid jabberId  or password")
            return
        }
        
        if self.xmppStream != nil
        {
            self.xmppStream?.disconnect()
            self.xmppStream = nil
        }
        
        var hostName = hostIp //"172.20.12.111"
        if !AWS_IP {
            if !PUBLIC_IP
            {
                hostName = "172.20.12.111" //"182.75.17.27"
            }
        }
        let hostPort: UInt16 = UInt16(chatConfiguration.hostPort)
        let userJID = XMPPJID(user: jabberId, domain: chatConfiguration.xmppDomain, resource: chatConfiguration.resource)
        
        
        
        
        self.connectionSatus = .initialized
        sendXmppStatusChangedOnServer(xmppStatus: .initialized)
        
        self.hostName = hostName
        self.userJID = userJID
        self.hostPort = hostPort
        self.password = password
        
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        
        
        
        
        // Stream Configuration
        self.xmppStream = XMPPStream()
        let xmppAutPing = XMPPAutoPing(dispatchQueue: DispatchQueue.main)
        xmppAutPing.activate(self.xmppStream!)
        xmppAutPing.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppAutPing.pingInterval = 10
        xmppAutPing.pingTimeout = 8
        self.xmppStream?.hostName = hostName
        self.xmppStream?.hostPort = hostPort
        self.xmppStream?.enableBackgroundingOnSocket = true
        self.xmppStream?.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream?.keepAliveInterval = MIN_KEEPALIVE_INTERVAL
        self.xmppStream?.myJID = userJID
        xmppRoster?.activate(xmppStream!)
        self.xmppStream?.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.isReady = true
    }
    
    /*
     static let config = Config()
     
     class func configure(profile : Profile, chatConfiguration : ChatConfiguration) {
     print("Chat : configure")
     
     guard let hostIp = chatConfiguration.hostIp,  let jabberId = profile.jabberId, let password = profile.password else {
     print("Chat : Inavlid jabberId  or password")
     return
     }
     
     var hostName = hostIp //"172.20.12.111"
     if PUBLIC_IP
     {
     hostName = "182.75.17.27"
     }
     let hostPort: UInt16 = UInt16(chatConfiguration.hostPort)
     let userJID = XMPPJID(user: jabberId, domain: chatConfiguration.xmppDomain, resource: chatConfiguration.resource)
     ChatManager.config.hostName = hostName
     ChatManager.config.userJID = userJID
     ChatManager.config.hostPort = hostPort
     ChatManager.config.password = password
     }
     
     private override init() {
     guard let hostName = ChatManager.config.hostName, let userJID = ChatManager.config.userJID, let hostPort = ChatManager.config.hostPort, let password = ChatManager.config.password else {
     print("Chat : you must call configure before accessing ChatManager.shared")
     fatalError("Error - you must call configure before accessing ChatManager.shared")
     }
     print("Chat : init")
     
     self.connectionSatus = .initialized
     self.hostName = hostName
     self.userJID = userJID
     self.hostPort = hostPort
     self.password = password
     
     xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
     
     // Stream Configuration
     self.xmppStream = XMPPStream()
     self.xmppStream?.hostName = hostName
     self.xmppStream?.hostPort = hostPort
     self.xmppStream?.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
     self.xmppStream?.myJID = userJID
     xmppRoster.activate(xmppStream!)
     
     super.init()
     self.xmppStream?.addDelegate(self, delegateQueue: DispatchQueue.main)
     }
     */
    
    func addDelegate(delegate : ChatManagerDelegate?)
    {
        self.delegate = delegate
    }
    
    func connect() {
        print("Chat : start connection")
        guard let stream = xmppStream else {
            print("Chat : invalid stream")
            return
        }
        if !stream.isDisconnected {
            return
        }
        self.connectionSatus = .connecting
        sendXmppStatusChangedOnServer(xmppStatus: .connecting)
        do {
            try stream.connect(withTimeout: XMPPStreamTimeoutNone)
        }catch {
            print("Chat : fail to Connected")
            self.connectionSatus = .failed
            sendXmppStatusChangedOnServer(xmppStatus: .failed)
        }
    }
    
    func sendMessage(toJabberId : String, message : String , name : String?, dateTime : Int64?) {
        
        print("Chat : send message : \(message)")
        guard let stream = xmppStream else {
            print("Chat : invalid stream")
            return
        }
        let receiverJid = XMPPJID(user: toJabberId, domain: "localhost", resource: nil)
        let msg = XMPPMessage(type: "chat", to: receiverJid)
        msg.addBody(message)
        msg.addSubject("\(name ?? "")::\(String(dateTime ?? Date().millisecondsSince1970))::chat")
        stream.send(msg)
        
    }
    
    func disconnect() {
        print("Chat : disconnect")
        guard let xmppStream = xmppStream else {
            print("Chat : invalid stream")
            return
        }
        goOffline()
        xmppStream.disconnect()
    }
    
    func goOnline() {
        print("Chat : goOnline")
        
        guard let stream = xmppStream,let myJID = stream.myJID else {
            print("Chat : invalid stream or myJID")
            return
        }
        let presence = XMPPPresence()
        stream.send(presence)
        
        let domain = myJID.domain
        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
            let priority = DDXMLElement.element(withName: "priority", stringValue: "24") as! DDXMLElement
            presence.addChild(priority)
        }
        stream.send(presence)
    }
    
    func goOffline() {
        print("Chat : goOffline")
        guard let stream = xmppStream else {
            print("Chat : invalid stream")
            return
        }
        let presence = XMPPPresence(type: "unavailable")
        stream.send(presence)
    }
}


extension ChatManager: XMPPStreamDelegate {
    
    func xmppStreamDidConnect(_ stream: XMPPStream) {
        print("Chat : Stream: Connected")
        self.connectionSatus = .connected
        sendXmppStatusChangedOnServer(xmppStatus: .connected)
        
        
        if let password = self.password {
            do {
                try stream.authenticate(withPassword: password)
            }
            catch {
                print("Chat : fail to authenticate")
                self.connectionSatus = .failed
                sendXmppStatusChangedOnServer(xmppStatus: .failed)
            }
        }else{
            print("Chat : password nil")
            self.disconnect()
        }
    }
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        print("Chat : Stream: Disconnect , error = \(String(describing: error?.localizedDescription))")
        self.connectionSatus = .failed
        sendXmppStatusChangedOnServer(xmppStatus: .failed)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        goOnline()
        self.connectionSatus = .ready
        print("Chat : stream authenticated")
        sendXmppStatusChangedOnServer(xmppStatus: .authenticate)
    }
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("Chat : time out")
        self.connectionSatus = .failed
    }
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("Chat : dint not auth, error :\(error)")
        self.connectionSatus = .failed
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("Chat : receive message \(String(describing: message))")
        handleIncomingMessage(message: message)
    }
    
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        delegate?.didSendMessage()
        print("Chat : message sent  \(String(describing: message))")
    }
    
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        print("Chat : failed to send message : \(message)")
        delegate?.didFailedMessage(mxppMessage: message.xmlString, error: error)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        print("Chat : did receive IQ")
        return false
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        
        print(presence)
        let presenceType = presence.type
        let username = sender.myJID?.user
        let presenceFromUser = presence.from?.user
        
        if presenceFromUser != username  {
            if presenceType == "available" {
                print("Chat : available")
            }
            else if presenceType == "subscribe" && presence.from != nil {
                self.xmppRoster?.subscribePresence(toUser: presence.from!)
            }
            else {
                print("Chat :presence type")
                print(presenceType ?? "")
            }
        }
    }
    
    
    func handleIncomingMessage(message : XMPPMessage)
    {
        guard let messageString = message.body , let from = message.fromStr?.components(separatedBy: "@").first else {
            print("Chat : invalid value of body,from or to in incoming message")
            return
        }
        if message.isErrorMessage {
            //TODO : Handel error message
            print("Chat : error message ")
        }else{
            
            let subjectComponents = message.subject?.components(separatedBy: "::")
            let name = subjectComponents?[0] ?? "Unknown"
            let dateString = subjectComponents?[1] ?? String(Date().millisecondsSince1970) // Add GMT date time
            let chatType = subjectComponents?[2] ?? ChatType.chat.rawValue
            
            var chatHistory = DatabaseManager.shared.getChatHistory(for: from)
            
            var getProfileDetail = false
            
            if chatHistory == nil {
                chatHistory = ChatHistory.init()
                chatHistory?.uniqueId = from
                chatHistory?.connectionStatus = ConnectionStatus.new.rawValue
                // profile not found so hit get profile details API and update hsitory and profile
                getProfileDetail = true
            }else {
                let oldCount = chatHistory?.unReadMessageCount ?? 0
                chatHistory?.unReadMessageCount = oldCount + 1
            }
            chatHistory?.name = name
            chatHistory?.createdDate = Int64(dateString) ?? 0
            chatHistory?.lastMessage = messageString
            
            DatabaseManager.shared.saveUpdateChatHistory(chatHistory: chatHistory!)
            
            if (getProfileDetail)
            {
                upadteProfileAndChatHistory(chatHistory: chatHistory!)
            }
            
            let chatId = UUID().uuidString
            
            var chat = ChatModel.init()
            chat.chatId = chatId
            chat.uniqueId = chatHistory?.uniqueId
            chat.messageSource = MessageSource.receive.rawValue
            chat.type = chatType
            chat.messageDate = chatHistory?.createdDate ?? 0
            chat.message = chatHistory?.lastMessage
            DatabaseManager.shared.saveUpdateChat(chat: chat)
            let sender = Sender(id: from, displayName: chatHistory?.name ?? "Unknown")
            ChatAlertViewManager.shared.handleChatNotifications(senderName: sender.displayName, chatModel: chat)
            
            guard let delegate = self.delegate else {
                return
            }
            
            //            let attributedText = NSAttributedString(string: messageString, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
            //            let message = MockMessage(attributedText: attributedText, sender: sender, messageId: chatId, date: Date.init(milliseconds: chatHistory?.createdDate ?? Date().millisecondsSince1970))
            //delegate.didReceiveMessage(mockMessage : message, from : from)
            print("Chat : handleIncomingMessage() - setDelegate ")
            delegate.didReceiveMessage(chat: chat, sender: sender)

        }
    }
    
    fileprivate func upadteProfileAndChatHistory(chatHistory : ChatHistory)
    {
        guard let uniqueId = chatHistory.uniqueId else {
            return
        }
        
        if Reachability.isInternetConnected()
        {
            RequestManager.shared.getProfileRequest(uniqueId: uniqueId, onCompletion: { (responseJson) in
                let response =  RegistrationResponse.init(json: responseJson)
                if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                {
                    if let profile = response.profile
                    {
                        DatabaseManager.shared.saveUpdateProfile(profile: profile)
                        var chatHistoryObj = chatHistory
                        chatHistoryObj.name = profile.name
                        chatHistoryObj.avatarUrl = profile.imageList?.first?.url
                        DatabaseManager.shared.saveUpdateChatHistory(chatHistory: chatHistoryObj)
                    }
                }
            }) { (error) in
            }
        }
    }
}


extension ChatManager {
    
    func manageChatMangerState(isForground: Bool) {
//        if isForground {
//            goOnline()
//        }else {
//            goOffline()
//        }
    }
    
    
}

extension ChatManager {
    func sendXmppStatusChangedOnServer(xmppStatus: XMPPConnectionSatus){
        AppAnalytics.log(.xmppStatus(status: xmppStatus.rawValue.capitalized))
        TPAnalytics.log(.xmppStatus(status: xmppStatus.rawValue.capitalized))
    }
}

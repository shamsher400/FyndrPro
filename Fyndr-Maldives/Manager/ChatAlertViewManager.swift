//
//  ChatAlertViewManager.swift
//  Fyndr
//
//  Created by Shamsher Singh on 30/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import NotificationView
import UserNotifications



class ChatAlertViewManager  {
    
    static let shared = ChatAlertViewManager()
    let notificationView = NotificationView.init()
    
    var chatModel: ChatModel?
    
    private init() {
        notificationView.delegate = self
    }
    
    
    func handleChatNotifications(senderName: String,chatModel: ChatModel) {
        print("handleChatNotifications() senderName= \(senderName)")

        if APP_DELEGATE.appCurrentState == AppState.background.rawValue {
            print("handleChatNotifications() AppState.background")
            sendBackgroundNotification(senderName: senderName, chatModel: chatModel)
        }else {
            print("handleChatNotifications() AppState.forground")

            showForgroundNotification(senderName: senderName, chatModel: chatModel)
        }
        
    }
    
    private func showForgroundNotification(senderName: String,chatModel: ChatModel) {
        let topViewController = APP_DELEGATE.getTopViewController()
        if topViewController?.isKind(of: ChatViewController.self) ?? false {
            if let chatVC =  topViewController as? ChatViewController {
                if chatVC.myProfile.uniqueId == chatModel.uniqueId
                {
                    return
                }
                show(senderName: senderName, chatModel: chatModel)
            }
        }else {
            show(senderName: senderName, chatModel: chatModel)
        }
    }
    
    private func show(senderName: String,chatModel: ChatModel) {
        self.chatModel = chatModel
        notificationView.title = senderName
        notificationView.body = chatModel.message
        notificationView.show()
    }
}

extension ChatAlertViewManager : NotificationViewDelegate {
    
    func notificationViewDidTap(_ notificationView: NotificationView) {
        let topVC = APP_DELEGATE.getTopViewController()
        print("topVC : \(String(describing: topVC))")
        if topVC?.isKind(of: RecentViewController.self) ?? false {
            if let chatModel = chatModel
            {
                if let uniqueId = chatModel.uniqueId {
                    APP_DELEGATE.openChatViewController(uniqueId: uniqueId)
                }
            }
        }else if let chatVC =  topVC as? ChatViewController {
            DispatchQueue.main.async {
                if let chatModel = self.chatModel
                {
                    if let uniqueId = chatModel.uniqueId {
                        chatVC.refreshChatViews(chatHistory: Util.getChatHistory(uniqId: uniqueId))
                    }
                }
            }
        }else {
            APP_DELEGATE.openRecentViewController()
        }
    }
    
    
    private func sendBackgroundNotification(senderName: String, chatModel: ChatModel) {
        let content = UNMutableNotificationContent()
        content.title = senderName
        if let message = chatModel.message, let uniqueId = chatModel.uniqueId{
            content.body = message
            content.userInfo = ["uniqueId": uniqueId]
        }
        content.sound = UNNotificationSound.default
        let timeInMiliSecond = Date().currentTimeMillis()
        print("notificationId --   \(timeInMiliSecond)")
        let request = UNNotificationRequest(
            identifier: "notification.id.\(timeInMiliSecond)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
    
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

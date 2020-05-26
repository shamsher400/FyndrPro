//
//  NotificationManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 07/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SafariServices

enum AlertType : String {
    case chat = "CHAT"
    case call = "M_CALL"
    case logout = "LOGOUT"
    case none = ""
}


class NotificationManager {
    
    static let shared = NotificationManager()
    private init() { }
    fileprivate var token : String?
    
    func registerForServerNotifications(pushToken : String?){
       
        if pushToken != nil
        {
            self.token = pushToken
        }
        
        guard let token = self.token, let myprofile = Util.getProfile(), let _ = myprofile.uniqueId  else {
           return
        }
        RequestManager.shared.registerPushTokenRequest(token: token, onCompletion: { (responseJson) in
            print("Notification : Push registration success")
        }) { (error) in
            print("Notification : Push registration failed")
        }
    }
    
    
    func handleNotification(userInfo : [AnyHashable : Any], application: UIApplication){
        
        print("Notification : payload : \(userInfo)")
        if let aps : [AnyHashable : Any] = userInfo["aps"] as? [AnyHashable : Any] {
            if let message : String = aps["alert"] as? String {
                print("Notification : message : \(message)")
                if let payload : [AnyHashable : Any] = aps["payload"] as? [AnyHashable : Any]{
                    if let type = payload["type"] as? String
                    {
                        if type == "LOGOUT"{
                            print("Notification : LOGOUT")
                            handleNotificationAlert(message: message, alertType: .logout, application: application)
                            return
                            
                        }else if type == "CHAT"{
                            print("Notification : CHAT")
                            handleNotificationAlert(message: message, alertType: .chat, application: application)
                            return
                        } else if type == "M_CALL"{
                            print("Notification : M_CALL")
                            handleNotificationAlert(message: message, alertType: .call, application: application)
                            return
                        }else if type == "SUB_OPS" {
                            if !Util.getSubscribeValidityIsAvalibale() {
                                if APP_DELEGATE.getTopViewController()?.isKind(of: SFSafariViewController.self) ?? false  {
                                    APP_DELEGATE.getTopViewController()?.dismiss(animated: true, completion: nil)
                                }
                            }
                        }else if type == "SUBSCRIPTION" {
                            SubscriptionManager.sharedInstance.handleSubscriptionCallBack()
                        }else if type == "UNSUBSCRIPTION" {
                            SubscriptionManager.sharedInstance.handleSubscriptionCallBack()
                        }else {
                            AlertView().showNotficationMessage(message: message)
                            print("Notification : Other")
                        }
                    }
                }
            }
        }
    }
    
    /*
    func handleNotification(userInfo : [AnyHashable : Any], application: UIApplication){
        
        print("Notification : payload : \(userInfo)")

        if let aps = userInfo["aps"] {
            let appDic = aps as! NSDictionary
            
            if let messageObj  = appDic.object(forKey: "alert") {
                let message = messageObj as! String
                
                if let alertTypeObj  = appDic.object(forKey: "alertType")
                {
                    let alertType = alertTypeObj as! String
                    
                    if alertType == "deactivate" {
                        handleDeactivateNotification(message: message)
                    }
                    else if (alertType == "0" || alertType == "missed") { // Handle incoming and missed call
                        // 0 for incoming
                        // 1 for missed call
                        
                        if(alertType == "0")
                        {
                            if (application.applicationState == .inactive || application.applicationState == .background  )
                            {
                                print("Notification Recived in Background")
                                // self.checkAndOpenFakeInComingCallView( forground : false)
                            }
                            else
                            {
                                print("Notification Recived in forground")
                                //self.checkAndOpenFakeInComingCallView( forground : true)
                            }
                        }
                    }
                    else {
                        if (application.applicationState == .inactive || application.applicationState == .background  )
                        {
                            print("Notification Recived in Background")
                            notificationAction(alertType: alertType)
                        }
                        else
                        {
                            print("Notification Recived in forground")
                            handleNotificationAlert(message: message, alertType: alertType)
                        }
                    }
                    if alertType == "update"
                    {
                        print("Refresh App Data From Server")
                    }
                }else {
                    AlertView().showNotficationMessage(message: message)
                }
            }
        }
    }
    */

    
    fileprivate func handleNotificationAlert(message : String, alertType : AlertType,application: UIApplication){
        
        switch alertType {
        case .logout:
            self.handleDeactivateNotification(message: message)
        default:
            AlertView().showNotficationMessage(message: message)
            break
        }
    }
    
    fileprivate func handleDeactivateNotification(message : String){
       // AlertView().showNotficationMessage(message: message)
        APP_DELEGATE.logoutFromDevice(message : message)
    }
    
}

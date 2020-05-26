//
//  AppAnalyticsEngine.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppAnalyticsEngine: AnalyticsEngine {
    
    let chunkCount = 5
    var requestInProgress = false
    
    func sendAnalyticsEvent(name: String, parameter: [String : Any]) {
       
        let parameters = JSON(parameter).description
        
        print("AppEevenLog -: \(name) : \(parameter)")
        DatabaseManager.shared.saveEventLog(eventName: name, parameter: parameters)
        if Reachability.isInternetConnected() {
            if isForceUpdate(name: name) {
                uploadEventOnServer()
            }else{
                checkAndUpdateEventLogOnServer()
            }
        }
    }
    
    fileprivate func isForceUpdate(name: String) -> Bool
    {
        return false
    }
    
    fileprivate func checkAndUpdateEventLogOnServer()
    {
        print("AppAnalyticsEngine : Check And Update log On Server : \(requestInProgress)")
        
        if !requestInProgress {
            let eventCount = DatabaseManager.shared.getEventLogCount()
            if eventCount >= chunkCount
            {
                uploadEventOnServer()
            }
        }
    }
    
    func uploadEventOnServer()
    {
        print("AppAnalyticsEngine : Upload log on server")
        if Reachability.isInternetConnected() {
            
            if let eventLogs = DatabaseManager.shared.getEventLogs()
            {
                if eventLogs.count > 0 {
                    self.requestInProgress = true
                    
                    RequestManager.shared.logEventRequest(events: eventLogs, onCompletion: { (responseJson) in
                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            print("AppAnalyticsEngine : Delete event log")
                            DatabaseManager.shared.deleteEventLogs(eventLogs: eventLogs)
                            self.checkAndUpdateEventLogOnServer()
                        }
                        self.requestInProgress = false
                    }) { (error) in
                        self.requestInProgress = false
                    }
                }
            }
        }
    }
}

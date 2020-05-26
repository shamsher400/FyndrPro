//
//  PurchaseSubscriptionVerifyOtp.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 14/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct  PurchaseSubscriptionVerifyOtp : Codable{
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let subscription = "subscription"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var subscription: SubscriptionDataObject?
    
    public init(){}
    
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        subscription = SubscriptionDataObject.init(subObj: json[SerializationKeys.subscription])
    }
    
    func save()
    {
        UserDefaults.standard.save(customObject: self, inKey: USER_DEFAULTS.APP_SUB)
        UserDefaults.standard.synchronize()
    }
    
    func getCheckSubData() -> CheckSubscriptionResponse?{
        if let appSubscriptions = UserDefaults.standard.retrieve(object: CheckSubscriptionResponse.self, fromKey: USER_DEFAULTS.APP_SUB)
        {
            return appSubscriptions
        }
        return nil
    }
}

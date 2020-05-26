//
//  CheckSubscriptionResponse.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 27/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct  CheckSubscriptionResponse : Codable{
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let subscription = "subscription"
        static let orderStatus = "orderStatus"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var orderStatus: String?
    public var subscription: SubscriptionDataObject?
    
    public init(){}
    
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        if let orderStatus = json[SerializationKeys.orderStatus].string {
            self.orderStatus = orderStatus
        }
        subscription = SubscriptionDataObject.init(subObj: json[SerializationKeys.subscription])
    }
    
    func save()
    {
        UserDefaults.standard.save(customObject: self, inKey: USER_DEFAULTS.APP_SUB)
        UserDefaults.standard.synchronize()
    }
    
    func getCheckSubData() -> CheckSubscriptionResponse?{
        
        return UserDefaults.standard.retrieve(object: CheckSubscriptionResponse.self, fromKey: USER_DEFAULTS.APP_SUB)
    }
}


struct SubscriptionDataObject: Codable {
    private struct SerializationKeys {
        static let statusStatus = "status"
        static let validity = "validityTimeStamp"
        static let currentTime = "currentTime"
        static let packId = "packId"
        static let subscribePack = "pack"
    }
    public var statusStatus: Bool?
    public var validity: Double?
    public var currentTime: Double?
    public var packId: String?
    public var subscribePack: SubscribePack?
    init(subObj: JSON) {
        statusStatus = subObj[SerializationKeys.statusStatus].bool
        validity = subObj[SerializationKeys.validity].doubleValue
        currentTime = subObj[SerializationKeys.currentTime].doubleValue
        packId = subObj[SerializationKeys.packId].string
        subscribePack = SubscribePack.init(subObj: subObj[SerializationKeys.subscribePack])
    }
}

struct SubscribePack: Codable {
    private struct SerializationKeys {
        static let packType = "packType"
        static let packName = "packName"
        static let productId = "productId"
        static let enabled = "enabled"
        static let description = "description"
    }
    public var packType: String?
    public var packName: String?
    public var productId: String?
    public var enabled: Bool?
    public var description: String?
    init(subObj: JSON) {
        packType = subObj[SerializationKeys.packType].string
        if let packName = subObj[SerializationKeys.packName].string {
            self.packName = packName.byteUTF8ToString()
        }
        productId = subObj[SerializationKeys.productId].string
        enabled = subObj[SerializationKeys.enabled].bool
        
        if let description = subObj[SerializationKeys.description].string {
            self.description = description.byteUTF8ToString()
        }

    }
}

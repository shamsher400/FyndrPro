//
//  PurchasePackResponse.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 03/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PurchasePackResponse : Codable {
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let orderId = "orderId"
        static let subStatus = "subStatus"
        static let subscription = "subscription"
        static let transactionUrl = "transactionUrl"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var orderId: String?
    public var subStatus: String?
    public var subscription: String?
    public var transactionUrl: String?
    
    
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        if let orderId = json[SerializationKeys.orderId].string { self.orderId = orderId}
        if let subStatus = json[SerializationKeys.subStatus].string { self.subStatus = subStatus}
        if let subscription = json[SerializationKeys.subscription].string { self.subscription = subscription}
        if let transactionUrl = json[SerializationKeys.transactionUrl].string { self.transactionUrl = transactionUrl}
    }
}



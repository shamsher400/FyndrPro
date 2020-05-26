//
//  AppPacksResponse.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 01/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON


struct AppPacksResponse : Codable {
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let packs = "packs"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var packs: [PacksModel]?
    
    
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        if let packsModelList = json[SerializationKeys.packs].array { packs = packsModelList.map { PacksModel.init(json: $0) } }
    }
}

struct PacksModel : Codable {
    
    private struct SerializationKeys {
        static let packId = "packId"
        static let productId = "productId"
        static let packType = "packType"
        static let price = "price"
        static let packName = "packName"
        static let description = "description"
        static let shortDescription = "shortDescription"
        static let validity = "validity"
        static let validityInDays = "validityInDays"
        static let graceTime = "graceTime"
    }
    
    
    public var packId :String?
    public var productId :String?
    public var packType :String?
    public var price : Float?
    public var packName :String?
    public var description :String?
    public var shortDescription :String?
    public var validity :Int?
    public var validityInDays :Int?
    public var graceTimee :Int?
    
    
    public init() {
    }
    
    public init(json: JSON){
        packId = json[SerializationKeys.packId].string
        productId = json[SerializationKeys.productId].string
        packType = json[SerializationKeys.packType].string
        price = json[SerializationKeys.price].float
        packName = json[SerializationKeys.packName].string?.byteUTF8ToString()
        description = json[SerializationKeys.description].string?.byteUTF8ToString()
        shortDescription = json[SerializationKeys.shortDescription].string?.byteUTF8ToString()
        validity = json[SerializationKeys.validity].int
        validityInDays = json[SerializationKeys.validityInDays].int
        if let graceTime = json[SerializationKeys.graceTime].int {
            graceTimee = graceTime
        }
    }
}


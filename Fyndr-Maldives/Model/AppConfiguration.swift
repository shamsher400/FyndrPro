//
//  AppConfiguration.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AppConfiguration : Codable {
    
    private struct SerializationKeys {
        
        static let status = "status"
        static let reason = "reason"
        static let baseUrl = "baseUrl"
        static let numberOfImages = "numberOfImages"
        static let calling = "calling"
        static let registrationMethods = "registrationMethods"
        static var interests = "interests"
        static var versionControll = "appUpdateStatus"
        static var subUrl = "subUrl"
        static var subEvents = "subEvents"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var baseUrl: String?
    public var numberOfImages: Int?
    public var calling: Bool? = false
    public var registrationMethods: [String]?
    public var interests: [Interest]?
    public var appVersion: AppVersionControll?
    public var subEvents: [ConfigSubEventModel]?

    
    public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /// Initiates the instance based on the JSON that was passed.
    /// - parameter json: JSON object from SwiftyJSON.
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        baseUrl = json[SerializationKeys.baseUrl].string
        numberOfImages = json[SerializationKeys.numberOfImages].int
        calling = json[SerializationKeys.calling].boolValue
        if let registrationMethodsList = json[SerializationKeys.registrationMethods].array { registrationMethods = registrationMethodsList.map { $0.stringValue } }
        if let interestItem = json[SerializationKeys.interests].array { interests = interestItem.map { Interest.init(json: $0)} }
        
        if let subEventsModel = json[SerializationKeys.subEvents].array { subEvents = subEventsModel.map { ConfigSubEventModel.init(json: $0)} }
        self.appVersion = AppVersionControll.init(json: json[SerializationKeys.versionControll])
    }
}



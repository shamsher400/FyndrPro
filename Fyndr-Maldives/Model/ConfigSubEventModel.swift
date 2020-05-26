//
//  ConfigSubEventModel.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 30/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON


struct ConfigSubEventModel : Codable{
    
    private struct SerializationKeys {
        static let policy = "policy"
        static let event = "event"
        static let subscription = "subscription"
    }
    
   
    
    public var policy : String?
    public var event : String?
    public var subscription : String?
    
    
    public init(json: JSON) {
        policy = json[SerializationKeys.policy].string
        event = json[SerializationKeys.event].string
        if let policis = json[SerializationKeys.policy].string {
            policy = policis
        }
    }
}

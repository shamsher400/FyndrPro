//
//  AppHeData.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 24/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AppHeData : Codable {
    
    private struct SerializationKeys {
        static let msisdn = "msisdn"
        static var status = "status"
    }
    
    // MARK: Properties
    public var status: String?
    public var msisdn: String?
    
    public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    // Initiates the instance based on the JSON that was passed.
    // - parameter json: JSON object from SwiftyJSON.
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        msisdn = json[SerializationKeys.msisdn].string
    }
}


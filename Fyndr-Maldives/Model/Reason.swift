//
//  Reason.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Reason : Codable {
    
    private struct SerializationKeys {
        static let id = "id"
        static let reason = "reason"
    }
    // MARK: Properties
    public var id: String?
    public var reason: String?
    
    public init(json: JSON) {
        id = json[SerializationKeys.id].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
    }
}

//
//  ReportReasons.swift
//  Fyndr
//
//  Created by BlackNGreen on 28/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ReportReasons : Codable {
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let reasons = "reasons"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var reasons: [Reason]?
    
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        if let reasonItem = json[SerializationKeys.reasons].array { reasons = reasonItem.map { Reason.init(json: $0) } }
    }
}

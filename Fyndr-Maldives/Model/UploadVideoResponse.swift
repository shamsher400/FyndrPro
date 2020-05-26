//
//  UploadVideoResponse.swift
//  Fyndr
//
//  Created by BlackNGreen on 18/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UploadVideoResponse : Codable {
    
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let thumbUrl = "thumbUrl"
        static let url = "url"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var thumbUrl: String?
    public var url: String?

    public init(json: JSON) {
        
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        thumbUrl = json[SerializationKeys.thumbUrl].string
        url = json[SerializationKeys.url].string
    }
}

//
//  SipConfiguration.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SipConfiguration: Codable {
    
    private struct SerializationKeys {
        static let ip = "ip"
        static let port = "port"
        static let shortcode = "shortcode"
        static let sipProtocol = "protocol"
        static let codecs = "codecs"
    }
    
    // MARK: Properties
    public var ip: String?
    public var port: String?
    public var shortcode: String?
    public var sipProtocol: String?
    public var codecs: [String?]?

    public init(json: JSON) {
        ip = json[SerializationKeys.ip].string
        port = json[SerializationKeys.port].string
        shortcode = json[SerializationKeys.shortcode].string
        sipProtocol = json[SerializationKeys.sipProtocol].string
        if let codecList = json[SerializationKeys.codecs].array { codecs = codecList.map { $0.string} }
    }
}

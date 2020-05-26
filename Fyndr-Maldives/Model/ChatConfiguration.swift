//
//  ChatConfiguration.swift
//  Fyndr
//
//  Created by BlackNGreen on 06/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ChatConfiguration: Codable {
    
    private struct SerializationKeys {
        static let hostIp = "hostIp"
        static let hostPort = "hostPort"
        static let resource = "resource"
        static let xmppDomain = "xmppDomain"
    }
    private struct SerializationValue {
        static let hostPort = 5222
        static let resource = "AppClient"
        static let xmppDomain = "localhost"
    }

    // MARK: Properties
    public var hostIp: String?
    public var hostPort : Int = SerializationValue.hostPort
    public var resource: String = SerializationValue.resource
    public var xmppDomain: String = SerializationValue.xmppDomain
    
    public init(json: JSON) {
        hostIp = json[SerializationKeys.hostIp].string
        hostPort = Int(json[SerializationKeys.hostPort].string ?? String(SerializationValue.hostPort)) ?? SerializationValue.hostPort
        resource = json[SerializationKeys.resource].string ?? SerializationValue.resource
        xmppDomain = json[SerializationKeys.xmppDomain].string ?? SerializationValue.xmppDomain
    }
    
}

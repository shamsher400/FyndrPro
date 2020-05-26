//
//  Response.swift
//  Fyndr
//
//  Created by BlackNGreen on 30/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Response {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let status = "status"
        static let reason = "reason"
        static let isLogout = "isLogout"
    }
    
    // MARK: Properties
    public var status: String?
    public var reason: String?
    public var isLogout: Bool = false

    
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    
    public init(json: JSON) {
        status = json[SerializationKeys.status].string
        reason = json[SerializationKeys.reason].string?.byteUTF8ToString()
        isLogout = json[SerializationKeys.isLogout].boolValue
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = reason { dictionary[SerializationKeys.reason] = value }
        dictionary[SerializationKeys.isLogout] = isLogout
        return dictionary
    }
}

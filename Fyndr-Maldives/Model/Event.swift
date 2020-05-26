//
//  Event.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct Event {
    
    private struct SerializationKeys {
        static let eventId = "eventId"
        static let name = "name"
        static let parameter = "parameter"
    }
    
    public var id: String?
    public var name: String?
    public var parameter: String?
    
    public init(id: String?,name : String?, parameter : String?) {
        self.id = id
        self.name = name
        self.parameter = parameter
    }
    
    public func dictionaryRepresentation() -> [String: Any]
    {
        var dictionary: [String: Any] = [:]
        // if let value = id { dictionary[SerializationKeys.eventId] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        
        if let value = parameter {
            if let data = value.data(using: .utf8) {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    dictionary[SerializationKeys.parameter] = jsonObj
                } catch {
                }
            }
        }
        return dictionary
    }
}

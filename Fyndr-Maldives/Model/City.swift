//
//  City.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct City: Codable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let id = "id"
        static let name = "name"
    }
    
    // MARK: Properties
    public var id: String?
    public var name: String?
    
    public init(id : String?, name : String?)
    {
        self.id = id
        self.name = name?.byteUTF8ToString()
    }
   
    public init(json: JSON) {
        id = json[SerializationKeys.id].string
        name = json[SerializationKeys.name].string?.byteUTF8ToString()
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = name { dictionary[SerializationKeys.name] = value.stringToUTF8Byte() }
        return dictionary
    }
}

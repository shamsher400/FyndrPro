//
//  ImageModel.swift
//  Fyndr
//
//  Created by BlackNGreen on 31/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ImageModel : Codable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let url = "url"
        static let name = "name"
        static let size = "size"
    }
    
    // MARK: Properties
    public var url: String?
    public var name: String?
    public var size: Int?

    public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    public init(url : String?,name: String?,size : Int?)
    {
        self.url = url
        self.name = name
        self.size = size
    }
    
    
    public init(json: JSON) {
        url = json[SerializationKeys.url].string
        name = json[SerializationKeys.name].string
        size = json[SerializationKeys.name].int

    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = url { dictionary[SerializationKeys.url] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        if let value = size { dictionary[SerializationKeys.size] = value }

        return dictionary
    }
}

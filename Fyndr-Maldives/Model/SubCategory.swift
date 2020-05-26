//
//  SubCategory.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SubCategory : Codable, Equatable {
    
    private struct SerializationKeys {
        static let id = "id"
        static let name = "name"
        static let selected = "selected"
        static let thumbUrl = "thumbUrl"
        static let selectedThumbUrl = "selectedThumbUrl"
    }
    
    public var id: String?
    public var name: String?
    public var selected : Bool = false
    public var thumbUrl: String?
    public var selectedThumbUrl: String?
    
    public init(id :String, name : String, thumbUrl: String )
    {
        self.id = id
        self.name = name
        self.thumbUrl = thumbUrl
        self.selectedThumbUrl = thumbUrl
    }
    

    public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    public init(json: JSON) {
        id = json[SerializationKeys.id].string
        name = json[SerializationKeys.name].string?.byteUTF8ToString()
        thumbUrl = json[SerializationKeys.thumbUrl].string
        selectedThumbUrl = json[SerializationKeys.selectedThumbUrl].string
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = name { dictionary[SerializationKeys.name] = value.stringToUTF8Byte() }
        if let value = thumbUrl { dictionary[SerializationKeys.thumbUrl] = value }
        if let value = selectedThumbUrl { dictionary[SerializationKeys.selectedThumbUrl] = value }
        dictionary[SerializationKeys.selected] = selected
        return dictionary
    }
    
    public static func == (lhs: SubCategory, rhs: SubCategory) -> Bool
    {
        return lhs.id == rhs.id
    }
    
}

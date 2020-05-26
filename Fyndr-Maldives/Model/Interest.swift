//
//  Interest.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Interest : Codable, Equatable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let id = "id"
        static let name = "name"
        static let thumbUrl = "thumbUrl"
        static let selectedThumbUrl = "selectedThumbUrl"
        static var subcategory = "subcategory"
    }
    
    // MARK: Properties
    public var id: String?
    public var name: String?
    public var thumbUrl: String?
    public var selectedThumbUrl: String?
    public var subcategory: [SubCategory]?

    public init(json: JSON) {
        id = json[SerializationKeys.id].string
        name = json[SerializationKeys.name].string?.byteUTF8ToString()
        thumbUrl = json[SerializationKeys.thumbUrl].string
        selectedThumbUrl = json[SerializationKeys.selectedThumbUrl].string
        if let subcategoryItem = json[SerializationKeys.subcategory].array {
            subcategory = subcategoryItem.map { SubCategory.init(json: $0)} }
    }
    
    public init(id: String?,name : String?, thumbUrl : String?) {
        self.id = id
        self.name = name
        self.thumbUrl = thumbUrl
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        if let value = thumbUrl { dictionary[SerializationKeys.thumbUrl] = value }
        if let value = selectedThumbUrl { dictionary[SerializationKeys.selectedThumbUrl] = value }
        if let value = subcategory { dictionary[SerializationKeys.subcategory] = value.map({$0.dictionaryRepresentation()}) }
        return dictionary
    }
    
    static func == (lhs: Interest, rhs: Interest) -> Bool {
        return lhs.id == rhs.id //&& lhs.name == rhs.name
    }
}




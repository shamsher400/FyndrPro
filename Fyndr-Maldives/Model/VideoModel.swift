//
//  VideoModel.swift
//  Fyndr
//
//  Created by BlackNGreen on 14/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct VideoModel : Codable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let url = "url"
        static let thumbUrl = "thumbUrl"
        static let name = "name"
        static let size = "size"
    }
    
    // MARK: Properties
    public var url: String?
    public var thumbUrl: String?
    public var name: String?
    public var size: Int?
    
    public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    public init(url : String?,thumbUrl : String?,name: String?,size : Int?)
    {
        self.url = url
        self.thumbUrl = thumbUrl
        self.name = name
        self.size = size
    }
    
    
    public init(json: JSON) {
        url = json[SerializationKeys.url].string
        thumbUrl = json[SerializationKeys.thumbUrl].string
        name = json[SerializationKeys.name].string
        size = json[SerializationKeys.size].int
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = url { dictionary[SerializationKeys.url] = value }
        if let value = thumbUrl { dictionary[SerializationKeys.thumbUrl] = value }
        if let value = name { dictionary[SerializationKeys.name] = value }
        if let value = size { dictionary[SerializationKeys.size] = value }
        
        return dictionary
    }
}

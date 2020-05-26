//
//  Country.swift
//  Fyndr
//
//  Created by BlackNGreen on 29/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Country {
    
    private struct SerializationKeys {
        static let name = "name"
        static let dialCode = "dial_code"
        static let code = "code"
    }
    
    // MARK: Properties
    public var name: String?
    public var dialCode: String?
    public var code: String?

    public init(json: JSON) {
        name = json[SerializationKeys.name].string
        dialCode = json[SerializationKeys.dialCode].string?.removeWhiteSpace()
        code = json[SerializationKeys.code].string
    }
    
    init(name: String?, dialCode: String?, code: String?) {
        self.name = name
        self.dialCode = dialCode
        self.code = code
    }
}


//
//  Language.swift
//  Fyndr-MMR
//
//  Created by BlackNGreen on 07/11/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

enum Language: Equatable {
    case english(English)
    case dhivehi
    
    enum English {
        case us
    }
}

extension Language {
    
    var code: String {
        switch self {
        case .english(let english):
            switch english {
            case .us:                return "en"
            }
        case .dhivehi:               return "dv"
        }
    }
    
    var langCodeOnServer: String {
        switch self {
        case .english(let english):
            switch english {
            case .us:                return "en"
            }
        case .dhivehi:               return "dv"
        }
    }
    
    var name: String {
        switch self {
        case .english(let english):
            switch english {
            case .us:                return "English"
            }
        case .dhivehi:               return "Dhivehi"
        }
    }
    
    var imageName: String {
        switch self {
        case .english(let english):
            switch english {
            case .us:                return "en_app"
            }
        case .dhivehi:               return "dv_app"
        }
    }
}

extension Language {
    
    init?(languageCode: String?) {
        guard let languageCode = languageCode else { return nil }
        switch languageCode {
        case "en":     self = .english(.us)
        case "dv":              self = .dhivehi
        default:                return nil
        }
    }
}

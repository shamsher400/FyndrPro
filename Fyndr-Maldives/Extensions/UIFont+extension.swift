//
//  UIFont+extension.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

enum FontWeight {
    case thin
    case regular
    case medium
    case semibold
    case bold
}

extension UIFont
{
    convenience init?(weight : FontWeight = .regular , size : CGFloat = CGFloat(integerLiteral: 17).dp) {
        
        switch weight {
        case .thin:
            self.init(name: "Lato-Thin", size: size)
            
        case .regular:
            self.init(name: "Lato-Regular", size: size)
            
        case .medium:
            self.init(name: "Lato-Medium", size: size)
            
        case .semibold:
            self.init(name: "Lato-Semibold", size: size)
            
        case .bold:
            self.init(name: "Lato-Bold", size: size)
        }
    }
    
    
    static func appFont(weight : FontWeight = .regular , size : CGFloat = CGFloat(integerLiteral: 17)) -> UIFont {
    
        if USE_CUSTOM_FONT
        {
            return UIFont.customFont(weight: weight, size: size)
        }else{
            return UIFont.defaultSystemFont(weight:weight,  size:size)
        }
    }
    
    static func autoScale(weight : FontWeight = .regular , size : CGFloat = CGFloat(integerLiteral: 17)) -> UIFont {
       
        if USE_CUSTOM_FONT
        {
            return UIFont.customFont(weight: weight, size: size.dp)
        }else{
            return UIFont.defaultSystemFont(weight:weight,  size:size.dp)
        }
    }
    
    fileprivate static func customFont(weight : FontWeight , size : CGFloat) -> UIFont {
        
        switch weight {
        case .thin:
            return UIFont(name: "Lato-Thin", size: size) ?? UIFont.systemFont(ofSize: size)
        case .regular:
            return UIFont(name: "Lato-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case .medium:
            return UIFont(name: "Lato-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        case .semibold:
            return UIFont(name: "Lato-Semibold", size: size) ?? UIFont.systemFont(ofSize: size)
        case .bold:
            return UIFont(name: "Lato-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
    }
    
    fileprivate static func defaultSystemFont(weight : FontWeight , size : CGFloat) -> UIFont {
        
        switch weight {
        case .thin:
            return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.thin)
        case .regular:
            return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.regular)
        case .medium:
            return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
        case .semibold:
            return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
        case .bold:
            return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
        }
    }
}

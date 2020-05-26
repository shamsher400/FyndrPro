//
//  ViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 15/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

extension UIColor {
    
    fileprivate static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    fileprivate static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return rgba(r, g, b, 1.0)
    }
    
    fileprivate static func hex(hex : String, alpha : CGFloat) -> UIColor
    {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    fileprivate static func hex(hex : String) -> UIColor
    {
        return self.hex(hex: hex, alpha: CGFloat(1.0))
    }
    
    // MARK: Public
    static let navBarGradientStartColor = hex(hex: "#0065A4")
    static let navBarGradientEndColor = hex(hex: "#0065A4")
    
    static let defaultGradientStartColor = hex(hex: "#ED1C24")
    static let defaultGradientEndColor = hex(hex: "#ED1C24")
    
    //static let chatBgColor = hex(hex: "#DAE1E9")
    static let chatBgColor = hex(hex: "#FFFFFF")

    static let appPrimaryColor = hex(hex: "#ED1C24")
    static let appPrimaryBlueColor = hex(hex: "#FAFAFA")

    static let bookmarkBadgeColor = hex(hex: "#FAFAFA")

    //static let chatTextBgColor = hex(hex: "#FAFAFA")
    static let chatTextBgColor = hex(hex: "#DAE1E9")

    static let borderColor = hex(hex: "#DAE1E9")

    static let categoryOutLineColor = hex(hex: "#ED1C24")
    static let selectedCategoryColor = hex(hex: "#EBAB00", alpha: 0.7)

    
   // static let borderColor = rgb(254, 250, 236)
    static let backgroundColor = rgb(67, 73, 110)
    static let scoreColor = rgb(255, 193, 45)
    static let textColor = UIColor.white
    static let playerBackgroundColor = rgb(84, 77, 126)
    static let brightPlayerBackgroundColor = rgba(101, 88, 156, 0.5)
    
    
    static let customGreenColor = hex(hex: "#25D366")
    static let customOrange = hex(hex: "FF9800")
    static let customRed = hex(hex: "ff0000")
    
    static let customLightGray = hex(hex: "#f2f2f2")
    static let customLightBlue = hex(hex: "8c8c8c")//#1C9CF6")
    
    static let appCityListTextColor = hex(hex: "#ED1C24")
    
    static let changeLanguageSelected = hex(hex: "#0065A4")



}

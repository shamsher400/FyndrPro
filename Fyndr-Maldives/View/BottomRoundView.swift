//
//  BottomRoundView.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 01/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

@IBDesignable
class BottomRoundView: UIView {
    
    @IBInspectable var bottomRadius: CGFloat = 5
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 1
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.2
    
    
    override func layoutSubviews() {
        
        let shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: bottomRadius, height: bottomRadius))
        //        layer.masksToBounds = false
        //        layer.shadowColor = shadowColor?.cgColor
        //        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        //        layer.shadowOpacity = shadowOpacity
        //        layer.shadowPath = shadowPath.cgPath
        
        let mask = CAShapeLayer()
        mask.path = shadowPath.cgPath
        layer.mask = mask
    }
}


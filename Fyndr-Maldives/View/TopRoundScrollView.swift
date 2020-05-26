//
//  TopRoundScrollView.swift
//  Fyndr
//
//  Created by BlackNGreen on 29/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

@IBDesignable
class TopRoundScrollView: UIScrollView {
    
    @IBInspectable var topRadius: CGFloat = 5
    override func layoutSubviews() {
        
        let shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: topRadius, height: topRadius))
        let mask = CAShapeLayer()
        mask.path = shadowPath.cgPath
        layer.mask = mask
    }
}

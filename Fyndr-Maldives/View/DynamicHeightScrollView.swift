//
//  DynamicHeightScrollView.swift
//  Fyndr
//
//  Created by BlackNGreen on 26/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class DynamicHeightScrollView: UIScrollView {
    
    fileprivate let topRadius: CGFloat = 15

    override func layoutSubviews() {
        super.layoutSubviews()
        
        //print(">>> intrinsicContentSize : \(intrinsicContentSize) frame : \(self.frame)")
        if intrinsicContentSize.height <= (SCREEN_HEIGHT - headerMinHeight + 45)
        {
            self.contentSize = CGSize(width: intrinsicContentSize.width, height: SCREEN_HEIGHT - headerMinHeight + 45)
          //  print(">>> intrinsicContentSize 11 : \(intrinsicContentSize) SCREEN_HEIGHT : \(SCREEN_HEIGHT)")
        }
        
        let shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: topRadius, height: topRadius))
        let mask = CAShapeLayer()
        mask.path = shadowPath.cgPath
        layer.mask = mask
    }
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

}

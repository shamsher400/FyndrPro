//
//  CircularImageView.swift
//  Fyndr
//
//  Created by BlackNGreen on 06/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

@IBDesignable
class CircularImageView: UIImageView {
    
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var borderColor: UIColor? = UIColor.clear

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func layoutSubviews() {
        layer.cornerRadius = self.bounds.size.width/2
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
        
    }

}

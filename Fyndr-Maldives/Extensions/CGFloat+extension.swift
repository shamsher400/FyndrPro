//
//  CGFloat+extension.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

extension CGFloat {
    /**
     The relative dimension to the corresponding screen size.
     
     //Usage
     let someView = UIView(frame: CGRect(x: 0, y: 0, width: 320.dp, height: 40.dp)
     **Warning** Only works with size references from @1x mockups.
     */
    var dp: CGFloat {
        // return (self / 320) * UIScreen.main.bounds.width
        return (self / 375) * UIScreen.main.bounds.width
    }
    
    // iPhone 5 - 320
    // iPhone 6, 7, 8 Plus — 414
    // iPhone 6, 7, 8, X — 375
}

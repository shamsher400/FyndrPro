//
//  UIViewExtension.swift
//  Fyndr
//
//  Created by BlackNGreen on 14/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

extension UIView {
    
//    @discardableResult   // 1
//    func fromNib<T : UIView>() -> T? {   // 2
//        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {    // 3
//            // xib not loaded, or its top view is of the wrong type
//            return nil
//        }
//        self.addSubview(contentView)     // 4
//        contentView.translatesAutoresizingMaskIntoConstraints = false   // 5
//       // contentView.layoutAttachAll(to: self)   // 6
//        return contentView   // 7
//    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}


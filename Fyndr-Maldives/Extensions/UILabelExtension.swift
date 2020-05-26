//
//  UILabelExtension.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

extension UILabel {
    // for Swift 4 add @objc for defaultFont to make UILabel.appearance() affect!
  
    @objc var defaultFont: UIFont? {
        get { return self.font }
        set {
            /* When ViewController still in navigation stack
             and appear each time, the font label will decrease
             till will disappear, so we need to call dp just one
             time for each label .*/
            
            // check if font is nil
            guard self.font != nil else {
                return
            }
            if self.tag == 0 {  // self.tag = 0 is default value .
                self.tag = 1
                
                print(">>>> old size : \(self.font.pointSize)")
                let newFontSize = self.font.pointSize.dp // we get old font size and adaptive it with multiply it with dp.
                let oldFontName = self.font.fontName
                print(">>>> new size : \(newFontSize) name : oldFontName : \(oldFontName)")

                self.font = UIFont(name: oldFontName, size: newFontSize) //and set new font here .
            }
        }
    }
    
    
    func substituteFont() {
        
        guard self.font != nil else {
            return
        }
        let newFontSize = self.font.pointSize.dp
        let oldFontName = self.font.fontName
        
        print(">>>> new size : \(newFontSize) name : oldFontName : \(oldFontName)")
        self.font = UIFont(name: oldFontName, size: newFontSize)
    }
}


// Add this in didFinishLaunchingWithOptions method in AppDelegate
//UILabel.appearance().defaultFont = UIFont.systemFont(ofSize: 25) // 25 has no affect



extension UITextField {
    // for Swift 4 add @objc for defaultFont to make UILabel.appearance() affect!
    
    @objc var defaultFont: UIFont? {
        get { return self.font }
        set {
            /* When ViewController still in navigation stack
             and appear each time, the font label will decrease
             till will disappear, so we need to call dp just one
             time for each label .*/
            
            // check if font is nil
            guard let font = self.font else {
                return
            }
            if self.tag == 0 {  // self.tag = 0 is default value .
                self.tag = 1
              //  print(">>>> TextField old size : \(font.pointSize)")
                let newFontSize = font.pointSize.dp
                let oldFontName = font.fontName
               // print(">>>> TextField new size : \(newFontSize) name : oldFontName : \(oldFontName)")
                self.font = UIFont(name: oldFontName, size: newFontSize) //and set new font here .
            }
        }
    }
}

extension UILabel {
    
    func startBlink() {
        UIView.animate(withDuration: 0.8,
                       delay:0.0,
                       options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.alpha = 0 },
                       completion: nil)
    }
    
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}

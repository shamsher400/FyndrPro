//
//  UIImageExtension.swift
//  Fyndr
//
//  Created by BlackNGreen on 19/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

extension UIImage
{
    func sizeInByte() -> Int
    {
        if let imageData = self.pngData() {
            let bytes = imageData.count
            // let kB = Double(bytes) / 1000.0 // Note the difference
            return bytes
        }
        return 0
    }
    
    func sizeInKB() -> Double
    {
        if let imageData = self.pngData() {
            let bytes = imageData.count
           // let kB = Double(bytes) / 1000.0 // Note the difference
            let KB = Double(bytes) / 1024.0 // Note the difference
            return KB
        }
        return 0
    }
    
    func sizeInMB() -> Double
    {
        if let imageData = self.pngData() {
            let bytes = imageData.count
            // let kB = Double(bytes) / 1000.0 // Note the difference
            let MB = Double(bytes) / 1024.0 * 1000// Note the difference
            return MB
        }
        return 0
    }

}

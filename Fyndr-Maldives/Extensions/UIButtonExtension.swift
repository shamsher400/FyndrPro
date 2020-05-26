//
//  UIButtonExtension.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Kingfisher

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWith : CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius : CGFloat
        {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    func setGradient(colors: [UIColor]) {
        
        if colors.count == 2
        {
            guard let sublayers : [CALayer] = layer.sublayers else {
                return
            }
            
            for sublayer in sublayers {
                if sublayer.isKind(of: CAGradientLayer.self)
                {
                    sublayer.removeFromSuperlayer()
                }
            }
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            
            //gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            //gradientLayer.endPoint = CGPoint(x: layer.bounds.width, y: layer.bounds.width)
            gradientLayer.colors = [colors[0].cgColor, colors[1].cgColor]
            gradientLayer.borderColor = layer.borderColor
            gradientLayer.borderWidth = layer.borderWidth
            gradientLayer.cornerRadius = layer.cornerRadius
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    /*
     func setGradientBackground(colors: [UIColor], startPoint: CAGradientLayer.Point = .topLeft, endPoint: CAGradientLayer.Point = .bottomLeft) {
     var updatedFrame = bounds
     updatedFrame.size.height += self.frame.origin.y
     let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors, startPoint: startPoint, endPoint: endPoint)
     //setBackgroundImage(gradientLayer.createGradientImage(), for:)
     setBackgroundImage(gradientLayer.createGradientImage(), for: .normal)
     }
     
     func applyGradient(colors: [UIColor], startPoint: CAGradientLayer.Point = .topLeft, endPoint: CAGradientLayer.Point = .bottomLeft) {
     let gradient = CAGradientLayer()
     gradient.frame = self.bounds
     gradient.colors = colours.map { $0.cgColor }
     gradient.locations = locations
     self.layer.insertSublayer(gradient, at: 0)
     }
     */
    
    func setKfImage(url: String,selectedUrl: String?, placeholder : UIImage?, uid: String)
    {
        var urlString = "\(url)?deviceId=\(Util.deviceId())&userId=\(uid)"
        if PUBLIC_IP {
            urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
        }
        let downloader = KingfisherManager.shared.downloader
        downloader.trustedHosts = Set([DOMAIN_NAME])
        
        if let url = URL.init(string: urlString)
        {
            
            print("extension UIButton :: thumb image url \(url)")
            
            self.kf.setBackgroundImage(with: url,for: .normal,placeholder: placeholder, options: [.requestModifier(Request.resourceHeader()), .downloader(downloader)]) { result in
                print(">>> Finish image downlaoding")
                //  self.kf.setBackgroundImage(with: url,for: .normal,placeholder: placeholder, options: [.requestModifier(Request.resourceHeader()), .downloader(downloader)])
                
                switch result {
                case .success(let imageObj):
                    print(">>> Finish image downlaoding 1111")
                    self.setBackgroundImage(imageObj.image, for: .normal)
                case .failure:
                    print(">>> Finish image downlaoding 2222")
                    
                    break
                }
            }
        }
        guard let selectedUrl = selectedUrl else {
            return
        }
        
        var selectedUrlString = "\(selectedUrl)?deviceId=\(Util.deviceId())&userId=\(uid)"
        if PUBLIC_IP {
            selectedUrlString = selectedUrlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
        }
        if let finalSelectedUrl = URL.init(string: selectedUrlString)
        {
            print("extension UIButton :: selected image url \(finalSelectedUrl)")
            self.kf.setBackgroundImage(with: finalSelectedUrl,for: .selected,placeholder: placeholder, options: [.requestModifier(Request.resourceHeader()), .downloader(downloader)]) { result in
                print("Finish image downlaoding")
                // self.kf.setBackgroundImage(with: url,for: .selected,placeholder: placeholder)
                // self.kf.setBackgroundImage(with: finalSelectedUrl,for: .selected,placeholder: placeholder, options: [.requestModifier(Request.resourceHeader()), .downloader(downloader)])
                
                switch result {
                case .success(let imageObj):
                    print(">>> Finish image downlaoding sss 1111")
                    self.setBackgroundImage(imageObj.image, for: .selected)
                case .failure:
                    print(">>> Finish image downlaoding sss 2222")
                    
                    break
                }
            }
        }
    }
    
}


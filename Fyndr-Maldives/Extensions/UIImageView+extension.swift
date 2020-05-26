//
//  UIImageView+extension.swift
//  Fyndr
//
//  Created by BlackNGreen on 30/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setKfImage(url: String, placeholder : UIImage?, uniqueId : String?)
    {
        var uid = uniqueId
        if uniqueId == nil
        {
            uid = Util.getProfile()?.uniqueId
        }
        if let uid = uid
        {
            print(">>>>>> urlString : \(Date.timeIntervalBetween1970AndReferenceDate) \(url)")

            var urlString = "\(url)?deviceId=\(Util.deviceId())&userId=\(uid)"
            if PUBLIC_IP {
                urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
            }
            if let url = URL.init(string: urlString)
            {
                let downloader = KingfisherManager.shared.downloader
                downloader.trustedHosts = Set([DOMAIN_NAME])
                self.kf.setImage(with: url, placeholder: placeholder, options: [.requestModifier(Request.resourceHeader()), .downloader(downloader)])            }
        }
    }
    
    
    func setKfImageWithCallBack(url: String, placeholder : UIImage?, uniqueId : String?)
    {
        var uid = uniqueId
        if uniqueId == nil
        {
            uid = Util.getProfile()?.uniqueId
        }
        if let uid = uid
        {
            var urlString = "\(url)?deviceId=\(Util.deviceId())&userId=\(uid)"
            if PUBLIC_IP {
                urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
            }
            if let url = URL.init(string: urlString)
            {
                let downloader = KingfisherManager.shared.downloader
                downloader.trustedHosts = Set([DOMAIN_NAME])
                self.kf.setImage(with: url, placeholder: placeholder, options: [.requestModifier(Request.resourceHeader()), .downloader(downloader)], progressBlock: nil) { (image, NSError, CacheType, URL) in
                    print("image Downloadde ")
                }
            }
        }
    }
}



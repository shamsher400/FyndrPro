//
//  NetworkReachability.swift
//  Fyndr-LKA
//
//  Created by Shamsher Singh on 03/12/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

import UIKit
import SystemConfiguration
import CoreTelephony

public class NetworkReachability: NSObject{
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    class func isInternetConnected() -> Bool {
        
        if self.currentReachabilityStatus() == .notReachable
        {
            return false
        }
        return true
    }
    
    class func isMobileNetwork() -> Bool{
        
        if self.currentReachabilityStatus() == .reachableViaWWAN
        {
            return true
        }
        return false
    }
    
    
    class func currentReachabilityStatus() -> ReachabilityStatus {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
    
    class func getNetworkType()->String {
        
        if self.currentReachabilityStatus() == .notReachable{
            return ""
        }else if self.currentReachabilityStatus() == .reachableViaWiFi{
            return "Wifi"
        }else if self.currentReachabilityStatus() == .reachableViaWWAN{
            
            let networkInfo = CTTelephonyNetworkInfo();
            let carrierType = networkInfo.currentRadioAccessTechnology
            switch carrierType{
            case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?: return "2G"
            case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?: return "3G"
            case CTRadioAccessTechnologyLTE?: return "4G"
            default: return ""
            }
        }
        return ""
        
    }
}

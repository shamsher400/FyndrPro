//
//  Log.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import CocoaLumberjack

class Log {
    

//    #ifdef DEBUG
//    static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
//    #else
//    static const DDLogLevel ddLogLevel = DDLogLevelWarning;
//    #endif

    static let shared = Log()
    
    private init(){
       configureLogger()
    }
    
    private func configureLogger()
    {
       // DDLog.add(DDOSLogger.sharedInstance) // Uses os_log
        
        DDLog.add(DDOSLogger.sharedInstance, with: .all)
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 5
        DDLog.add(fileLogger)
        
      //  print("currentFileInfo : \(fileLogger.currentLogFileInfo)")
    }
    
    func v(_ message : String) {
        DDLogVerbose(message)
    }
    func d(_ message : String) {
        DDLogDebug(message)
    }
    func i(_ message : String) {
        DDLogInfo(message)
    }
    func w(_ message : String) {
        DDLogWarn(message)
    }
    func e(_ message : String) {
        DDLogError(message)
    }
}

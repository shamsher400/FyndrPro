//
//  AppVersionControll.swift
//  Fyndr
//
//  Created by Shamsher Singh on 29/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON


enum AppVersionAction : String {
    case FORCEUPDATE = "FORCEUPDATE"
    case SKIPUPDATE = "SKIPUPDATE"
    case LATEST = "LATEST"
}

struct AppVersionControll: Codable {
    private struct SerializationKeys {
        static let updateMessage = "updateMessage"
        static let primaryButtonText = "primaryButtonText"
        static var secondaryButtonText = "secondaryButtonText"
        static var titleMessage = "titleMessage"
        static var appVersion = "appVersion"
        static var appUpdateAction = "appUpdateAction"
    }
    
    // MARK: Properties
    public var updateMessage =  NSLocalizedString("M_UPDATE_MESSAGE", comment: "")
    public var primaryButtonText = NSLocalizedString("M_UPDATE_PRIMARY_BTN_TEXT", comment: "")
    public var secondaryButtonText = NSLocalizedString("Skip", comment: "")
    public var titleMessage = NSLocalizedString("M_UPDATE_TITLE", comment: "")
    public var appVersion: String?
    public var appUpdateAction: String?
    public var appStoreVersion: String?
    public var isUpdateSkiped = false
    
    public init(){
        
    }
    
    public init(json: JSON) {
        
        if let updateM = json[SerializationKeys.updateMessage].string?.byteUTF8ToString(){
            updateMessage = updateM
        }
        if let primaryBtn = json[SerializationKeys.primaryButtonText].string?.byteUTF8ToString(){
            primaryButtonText = primaryBtn
        }
        if let secondaryBtn = json[SerializationKeys.secondaryButtonText].string?.byteUTF8ToString(){
            secondaryButtonText = secondaryBtn        }
        if let titleM = json[SerializationKeys.titleMessage].string?.byteUTF8ToString(){
            titleMessage = titleM
        }
        if let appV = json[SerializationKeys.appVersion].string{
            appVersion = appV
        }
        if let appUpdateA = json[SerializationKeys.appUpdateAction].string{
            appUpdateAction = appUpdateA
        }
        
        if let appVersionModel = getVersionInfo() {
            appStoreVersion = appVersionModel.appStoreVersion
            isUpdateSkiped = appVersionModel.isUpdateSkiped
        }
        
        save()
    }
    
    func save()
    {
        UserDefaults.standard.save(customObject: self, inKey: USER_DEFAULTS.APP_VERSION_INFO)
        UserDefaults.standard.synchronize()
    }
    
    func getVersionInfo() -> AppVersionControll?{
        if let saveVersion = UserDefaults.standard.retrieve(object: AppVersionControll.self, fromKey: USER_DEFAULTS.APP_VERSION_INFO)
        {
            return saveVersion
        }
        return nil
    }
        
}



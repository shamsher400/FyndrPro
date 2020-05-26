//
//  BundleExtension.swift
//  Fyndr-MMR
//
//  Created by BlackNGreen on 07/11/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

private var bundleKey: UInt8 = 0

final class BundleExtension: Bundle {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return (objc_getAssociatedObject(self, &bundleKey) as? Bundle)?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    
    static let once: Void = { object_setClass(Bundle.main, type(of: BundleExtension())) }()
    
    static func set(language: Language) {
        Bundle.once
        
        let isLanguageRTL = Locale.characterDirection(forLanguage: language.code) == .rightToLeft
        UIView.appearance().semanticContentAttribute = isLanguageRTL == true ? .forceRightToLeft : .forceLeftToRight
        
        UserDefaults.standard.set(isLanguageRTL,   forKey: "AppleTe  zxtDirection")
        UserDefaults.standard.set(isLanguageRTL,   forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        let langCode = UserDefaults.standard.value(forKey: "AppleLanguages")
        print("langCode : \(String(describing: langCode))")
        
        guard let path = Bundle.main.path(forResource: language.code, ofType: "lproj") else {
            print("Failed to get a bundle path.")
            return
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle(path: path), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    
    static func getCurrentLanguage() -> Language
    {
        guard let langCodeList = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String] else {
            return Language.dhivehi
        }
        guard let langCode = langCodeList.first else{
            return Language.dhivehi
        }
        return Language.init(languageCode: langCode) ?? Language.dhivehi
    }
}

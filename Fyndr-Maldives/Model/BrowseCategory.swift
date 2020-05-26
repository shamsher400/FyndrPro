//
//  BrowseCategory.swift
//  Fyndr
//
//  Created by BlackNGreen on 19/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

class BrowseCategory : Codable {
    
    public var categories : [Interest]!
    
    init()
    {
        if let lastSavedCategory = UserDefaults.standard.retrieve(object: BrowseCategory.self, fromKey: USER_DEFAULTS.BROWSE_CATEGORY_LIST)
        {
            self.categories = lastSavedCategory.categories
        }else {
            self.categories = [Interest.init(id: SEARCH_TYPE_DEFAULT, name: "MyMatch", thumbUrl: nil)]
        }
    }
    
    func initWithCategoryList(categories : [Interest]?)
    {
        if categories != nil
        {
            self.categories = categories
        }else{
            self.categories.removeAll()
        }
        
    //    let defaultInterest = Interest.init(id: SEARCH_TYPE_DEFAULT, name: "MyMatch", thumbUrl: nil)
    //    self.categories?.insert(defaultInterest, at: 0)
    }

    func save()
    {
        UserDefaults.standard.save(customObject: self, inKey: USER_DEFAULTS.BROWSE_CATEGORY_LIST)
        UserDefaults.standard.synchronize()
    }
}

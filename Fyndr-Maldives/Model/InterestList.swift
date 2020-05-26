//
//  InterestList.swift
//  Fyndr
//
//  Created by BlackNGreen on 30/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct InterestList : Codable {

    public var interests : [Interest]?
    public var subCategories = [SubCategory]()
    
    init(interests : [Interest]?) {
        self.interests = interests
        self.subCategories.removeAll()
        
        if let subCategoryList = interests?.compactMap({ (interest) in
            interest.subcategory}) {
            for subCategoryObjList : [SubCategory] in subCategoryList {
                self.subCategories.append(contentsOf: subCategoryObjList)
            }
        }
    }
}

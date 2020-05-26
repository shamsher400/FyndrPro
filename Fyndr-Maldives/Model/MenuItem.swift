//
//  MenuItem.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

enum MenuAction {
    case app
    case html
}

struct MenuItem {
    var menuTitle : String
    var menuThumb : String
    var menuAction : MenuAction
    var menuUrl : String
    var tag : String

    init(menuTitle : String,menuThumb : String, menuAction : MenuAction, menuUrl: String, tag : String)
    {
        self.menuTitle = menuTitle
        self.menuAction = menuAction
        self.menuUrl = menuUrl
        self.menuThumb = menuThumb
        self.tag = tag
    }
    
}

//
//  ViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 15/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//



import UIKit

fileprivate extension UINib {
    
    static func nib(named nibName: String) -> UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
    
    static func loadSingleView(_ nibName: String, owner: Any?) -> UIView {
        return nib(named: nibName).instantiate(withOwner: owner, options: nil)[0] as! UIView
    }
}


// MARK: App Views
extension UINib {
    class func loadPlayerScoreboardMoveEditorView(_ owner: AnyObject) -> UIView {
        return loadSingleView("PlayerScoreboardMoveEditorView", owner: owner)
    }
    
    class func loadBrowseProfileOverlayView(_ owner: AnyObject) -> UIView {
        return loadSingleView("BrowseProfileOverlayView", owner: owner)
    }
}

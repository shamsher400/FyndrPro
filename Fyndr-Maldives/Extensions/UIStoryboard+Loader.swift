//
//  ViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 15/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

fileprivate enum Storyboard : String {
    case main = "Main"
}

fileprivate extension UIStoryboard {
    
    static func loadFromMain(_ identifier: String) -> UIViewController {
        return load(from: .main, identifier: identifier)
    }
    // add convenience methods for other storyboards here ...
    
    // ... or use the main loading method directly when instantiating view controller
    // from a specific storyboard
    static func load(from storyboard: Storyboard, identifier: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        return uiStoryboard.instantiateViewController(withIdentifier: identifier)
    }
}

// MARK: App View Controllers

extension UIStoryboard {
    static func loadGameScoreboardEditorViewController() -> UIViewController {
        return loadFromMain("ViewController")
    }
    
    static func loadRootViewController() -> UIViewController {
        return loadFromMain("HomeNavController")
    }
    
    static func loadRegistationFlow() -> UIViewController {
        return loadFromMain("RegistartionNavController")
    }

    
    static func loadCreateProfileViewController() -> UIViewController {
        return loadFromMain("CreateProfileViewController")
    }
    
    static func loadProfilePicEditViewController() -> UIViewController {
        return loadFromMain("ProfilePicEditViewController")
    }
    
    static func loadEditProfileViewController() -> UIViewController {
        return loadFromMain("EditProfileViewController")
    }
    
    static func getViewController(identifier : String) -> UIViewController {
        return loadFromMain(identifier)
    }
}

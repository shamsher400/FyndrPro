//
//  ViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 15/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
//import FacebookLogin
//import FacebookCore

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // initLocation()
    }
    
    @IBAction func btnFbLogin(_ sender : AnyObject)
    {
        /*
        FacebookLoginManager.init().getFacebookProfile(vc: self, onSuccess: { (profile) in
            print("profile : \(String(describing: profile))")
            
        }) { (error) in
            print("error : \(String(describing: error))")
        }
        */
       // (UIApplication.shared.delegate as! AppDelegate).changeVC()
    }
    
    @IBAction func btnFbLogin2(_ sender : AnyObject)
    {
       // getCurrentPlace()
        Log.shared.d("Hello")
        print("Hi Hi Hi")
        
    }
}

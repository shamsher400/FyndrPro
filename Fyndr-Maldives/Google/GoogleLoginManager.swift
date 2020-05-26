//
//  GoogleLoginManager.swift
//  Fyndr
//
//  Created by Shamsher Singh on 17/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import GoogleSignIn


class GoogleLoginManager: NSObject,GIDSignInDelegate {
    
    let TAG = "GoogleLoginManager"
    
    var gLoginCompleted : ((Error?, SocialProfileModel?) -> Void)?
    
    public typealias success = (_ googleProfile : SocialProfileModel?) -> Void
    public typealias failure = (_ error: Error?) -> Void
    
    func login(controller: UIViewController) {
        GIDSignIn.sharedInstance().delegate = (controller as! GIDSignInDelegate)
        GIDSignIn.sharedInstance().presentingViewController = controller
        GIDSignIn.sharedInstance().signIn()

    }
    
//    func getGoogleProfile(vc : UIViewController, onSuccess : @escaping success,  onFailure : @escaping failure) {
//
//        if GIDSignIn.sharedInstance()?.hasPreviousSignIn() ?? false {
//            getUserLoginData(vc: vc, onSuccess: { (profile) in
//                onSuccess(profile)
//            }) { (error) in
//                onFailure(error)
//            }
//        }else {
//            login(controller: vc)
//        }
//
//    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
                print(" gLoginCompleted is not set ")

    }
    
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        print(" gLoginCompleted is not set ")
//
//        guard let gLoginCompleted = self.gLoginCompleted else {
//            print(TAG + " gLoginCompleted is not set ")
//            return
//        }
//        if let user = user {
//            let profile = SocialProfileModel.init(user: user)
//            gLoginCompleted(nil , profile)
//        }else {
//
//            if let error = error {
//                gLoginCompleted(error , nil)
//            }else {
//                gLoginCompleted(nil , nil)
//
//            }
//
//        }
//    }
    
    func getUserLoginData(vc : UIViewController, gidUser :GIDGoogleUser?, onSuccess : @escaping success,  onFailure : @escaping failure){
        if let currentIUser = gidUser {
            let profileData =  SocialProfileModel.init(user: currentIUser)
            onSuccess(profileData)
        }else {
            onFailure(nil)
        }
    }
}

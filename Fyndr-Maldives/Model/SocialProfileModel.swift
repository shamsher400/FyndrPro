//
//  SocialProfileModel.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 26/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import GoogleSignIn
import AuthenticationServices

struct SocialProfileModel
{
    var userId : String?
    var name : String?
    var email : String?
    var picUrl : String?
    
    // Parse google siginIn
    init(user : GIDGoogleUser) {
        userId = user.userID // Safe to send to the server
        name = user.profile.name
        email = user.profile.email
        let dimension = round(100 * UIScreen.main.scale)
        picUrl = user.profile.imageURL(withDimension: UInt(dimension))?.absoluteString
    }
    
    @available(iOS 13.0, *)
    init(appleIdCredential :ASAuthorizationAppleIDCredential){
        self.userId = appleIdCredential.user
        self.name = (appleIdCredential.fullName?.givenName ?? " ") + " " + (appleIdCredential.fullName?.familyName ?? " ")
        self.email = appleIdCredential.email
    }
    
    // Facebook SiginIn
    init(result : [String : Any]?) {
        self.userId = result?["id"] as? String
        self.name = result?["name"] as? String
        self.email = result?["email"] as? String
        if let thumbUrl = ((result?["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
            self.picUrl = thumbUrl
        }
    }
    
}

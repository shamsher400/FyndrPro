//
//  SocialLoginVC.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 24/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import GoogleSignIn
import Lottie
import SwiftyJSON
import Accounts
import AuthenticationServices


class SocialLoginVC: UIViewController {
    
    @IBOutlet weak var btnFacebookLogin: UIButton!
    @IBOutlet weak var btnGoogleLogin: UIButton!
    @IBOutlet weak var btnAppleLogin: UIButton!
    
    fileprivate var animationViewBg: UIView?
    fileprivate let TAG = "SocialLogin : "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Sign Up", comment: "")
        btnGoogleLogin.setTitle(NSLocalizedString("M_LOGIN_WITH_GOOGLE", comment: ""), for: .normal)
        btnFacebookLogin.setTitle(NSLocalizedString("M_LOGIN_WITH_FACEBOOK", comment: ""), for: .normal)
        btnAppleLogin.setTitle(NSLocalizedString("M_LOGIN_WITH_APPLE", comment: ""), for: .normal)
        
        if #available(iOS 13.0, *) {
            btnAppleLogin.isHidden = false
        } else {
            btnAppleLogin.isHidden = true
        }
        
    }
    @IBAction func btnFacebookLogin(_ sender: Any) {
        
        FacebookLoginManager.init().getFacebookProfile(vc: self, onSuccess: { (profile) in
            print("profile : \(String(describing: profile))")
            if let profileData = profile {
                self.registerUser(registrationMethod: .FB, socialProfile: profileData)
            }
            
        }) { (error) in
            print("error : \(String(describing: error))")
        }
    }
    @IBAction func btnGoogleLogin(_ sender: Any) {
        
        let gidUser = GIDSignIn.sharedInstance()?.currentUser
        if gidUser == nil{
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().presentingViewController = self
            GIDSignIn.sharedInstance().signIn()
        }else {
            let gidUserData = SocialProfileModel.init(user: gidUser!)
            self.registerUser(registrationMethod: .GOOGLE, socialProfile: gidUserData)
        }
    }
    @available(iOS 13.0, *)
    @IBAction func btnAppleLogin(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    fileprivate func registerUser(registrationMethod : RegistrationMethods, socialProfile: SocialProfileModel)
    {
        
        if Reachability.isInternetConnected()
        {
            startAnimation()
            RequestManager.shared.socialRegistrationRequest( registrationMethod: registrationMethod, socialProfile: socialProfile  , onCompletion: { (responseJson) in
                print("registerUser()  \(responseJson)")
                DispatchQueue.main.async {
                    let response = RegistrationResponse.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        self.processRegistartionResponse(response: response, socialProfile: socialProfile, registrationMethod: registrationMethod)
                    }else{
                        self.stopAnimation()
                        self.showSystemError(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }) { (error) in
                self.stopAnimation()
                print("\(self.TAG) error : \(String(describing: error?.localizedDescription))")
                self.showSystemError(message: NSLocalizedString("M_LOGIN_ERROR", comment: ""))
            }
        }else {
            self.stopAnimation()
            self.showSystemError(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    fileprivate func processRegistartionResponse(response : RegistrationResponse,socialProfile: SocialProfileModel, registrationMethod : RegistrationMethods )
    {
        var myProfile = Util.getProfile()
        
        if response.isProfile
        {
            myProfile = response.profile
            myProfile?.registrationMethod = registrationMethod.rawValue
        }else{
            myProfile = Profile.init(json: JSON())
            myProfile?.uniqueId = response.uniqueId
            myProfile?.jabberId = response.jabberId
            myProfile?.password = response.password
            myProfile?.registrationMethod = registrationMethod.rawValue
            myProfile?.name = socialProfile.name
            myProfile?.email = socialProfile.email
        }
        //   myProfile?.isInterest = true
        myProfile?.isRegister = true
        Util.saveProfile(myProfile: myProfile)
        
        if let token = response.token {
            UserDefaults.standard.set(token, forKey: USER_DEFAULTS.AUTH_TOKEN)
            UserDefaults.standard.synchronize()
        }
        if let uniqueId = response.uniqueId {
            UserDefaults.standard.set(uniqueId, forKey: USER_DEFAULTS.USER_ID)
            UserDefaults.standard.synchronize()
            APP_DELEGATE.openScreen(screenName: Util.getCurrentScreen().0, firstScreen: false)
        }
        Util.setChatConfiguration(chatConfiguration: response.chatConfiguration)
        Util.setSipConfiguration(sipConfiguration: response.sipConfiguration)
        
        APP_DELEGATE.initChatManager(myProfile: myProfile, chatConfiguration: response.chatConfiguration)
        NotificationManager.shared.registerForServerNotifications(pushToken: nil)
        
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.GET_BOOKMARK)
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.GET_BLOCKLIST)
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.GET_CHAT_HISTORY)
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.RECENT_SUCCESS)
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.CONNECTIONS_SUCCESS)
        
        UserDefaults.standard.synchronize()
    }
    
    private func stopAnimation() {
        if animationViewBg != nil {
            animationViewBg?.isHidden = true
        }
    }
    private func startAnimation() {
        
        if animationViewBg == nil {
            animationViewBg = UIView.init()
            animationViewBg?.backgroundColor = UIColor.white
            self.view.addSubview(animationViewBg!)
            animationViewBg?.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                (animationViewBg?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0))!,
                (animationViewBg?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0))!,
                (animationViewBg?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0))!,
                (animationViewBg?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0))!
            ])
            
            let imageView = UIImageView()
            let image = UIImage(named: "app_icon")
            animationViewBg?.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                (imageView.centerXAnchor.constraint(equalTo: animationViewBg!.centerXAnchor)),
                (imageView.centerYAnchor.constraint(equalTo: animationViewBg!.centerYAnchor))
            ])
            imageView.image = image
        }
        animationViewBg?.isHidden = false
    }
    
    
    fileprivate func showSystemError(message : String)
    {
        AlertView().showAlert(vc: self, title: "", message: message, okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
    }
}


// Apple login
@available(iOS 13.0, *)
extension SocialLoginVC: ASAuthorizationControllerDelegate{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
            
            let appleUserProfile = SocialProfileModel.init(appleIdCredential: appleIDCredential)
            self.registerUser(registrationMethod: .APPLE, socialProfile: appleUserProfile)
            
        }
        
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // Handle error.
            print("Aple login error \(error.localizedDescription)")
        }
        
    }
}

extension SocialLoginVC {
    
    override func viewWillAppear(_ animated: Bool) {
        openScreenEvent()
    }
    
    private func openScreenEvent(){
        AppAnalytics.log(.openScreen(screen: .social))
        TPAnalytics.log(.openScreen(screen: .social))
    }
}



extension SocialLoginVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            let gidUserData = SocialProfileModel.init(user: user)
            self.registerUser(registrationMethod: .GOOGLE, socialProfile: gidUserData)
        }else {
            print("\(TAG)  Google login error \(error.localizedDescription)")
        }
    }
}

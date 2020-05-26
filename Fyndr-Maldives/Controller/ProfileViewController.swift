//
//  ProfileWithImageViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import KYDrawerController

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: DynamicHeightScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerBlurView: UIView!
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var bottomVersionView: UIView!

    @IBOutlet weak var profilePic : UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var cityLbl : UILabel!
    @IBOutlet weak var appVersionLbl : UILabel!
    
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var subscribeTitleLbl: UILabel!
    @IBOutlet weak var subscribeSubTitleLbl: UILabel!
    @IBOutlet weak var subscribeNowLbl: UILabel!
    
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgSubscribeIcon: UIImageView!
    var headerMaxHeight: CGFloat = 300
    var headerMaxHeightForScroll: CGFloat = 360
    
    let TAG = "ProfileViewController :: "
    
    var myProfile : Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let drawerController = APP_DELEGATE.window?.rootViewController as? KYDrawerController
        {
            drawerController.view.removeGestureRecognizer(drawerController.panGesture)            
        }
        
        headerMaxHeight = SCREEN_WIDTH
        if SCREEN_HEIGHT > 568
        {
            headerMaxHeight = headerMaxHeight*5/4
        }
        headerMaxHeightForScroll = headerMaxHeight*1.1
        
        self.appVersionLbl.text = "\(NSLocalizedString("version", comment: "")) \(Util.getAppVersion())"
        nameLbl.font = UIFont.autoScale(weight: .regular, size: 23)
        cityLbl.font = UIFont.autoScale(weight: .regular, size: 15)
        
        subscribeTitleLbl.font = UIFont.autoScale(weight: .regular, size: 15)
        subscribeSubTitleLbl.font = UIFont.autoScale(weight: .regular, size: 13)
        subscribeNowLbl.font = UIFont.autoScale(weight: .regular, size: 11)
        appVersionLbl.font = UIFont.autoScale(weight: .regular, size: 12)
        
        if let drawerController = APP_DELEGATE.window?.rootViewController as? KYDrawerController
        {
            drawerController.screenEdgePanGestureEnabled = false
        }
        
        
        // Localization
        
        subscribeTitleLbl.text = NSLocalizedString("M_PREMIUME_ACCESS", comment: "")
        
        subscribeSubTitleLbl.text = NSLocalizedString("M_GET_PREMIUME_ACCESS", comment: "")
        
        subscribeNowLbl.text = NSLocalizedString("M_SUBSCRIBE_NOW", comment: "")
        
        
        btnEdit.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
        
//        let bottomConstraint = NSLayoutConstraint(item: bottomVersionView, attribute: .bottom, relatedBy: .equal, toItem: scrollContainerView, attribute: .bottom, multiplier: 1, constant: 40.0)
//        bottomVersionView.translatesAutoresizingMaskIntoConstraints = false

//       scrollContainerView.addConstraint(bottomConstraint)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerViewHeightConstraint.constant = headerMaxHeight
        scrollView.contentOffset.y = 0
        headerBlurView.backgroundColor = UIColor.clear
        
        self.navigationController?.isNavigationBarHidden = true
        myProfile = Util.getProfile()
        setUIValues()
        sendOpenPageEvent()
        
        validateSubscriptions()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNessage(notification:)), name: NSNotification.Name(rawValue: "subscriptionNotify"), object: nil)
        
//        self.view.setNeedsDisplay()
        self.view.layoutIfNeeded()

    }
    
    
    @objc func receiveNessage(notification : Notification) {
        let dic = notification.userInfo
        
        if let dics = dic {
            var pendingPackId = PendingPackModel.init()
            pendingPackId = pendingPackId.getPendingPackModel() ?? PendingPackModel.init()
            pendingPackId.packId = dics["packId"] as? String ?? ""
            pendingPackId.orderId = dics["orderId"] as? String ?? ""
            pendingPackId.status = dics["status"] as? String ?? ""
            pendingPackId.save()
            
            validateSubscriptions()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "subscriptionNotify"), object: nil)
    }
    
    fileprivate func setUIValues()
    {
        nameLbl.text = myProfile?.name
        cityLbl.text = myProfile?.city?.name
        
        guard let profile = self.myProfile, let uniqueId = profile.uniqueId else {
            return
        }
        
        if let urlString = myProfile?.imageList?.first?.url
        {
            profilePic.setKfImage(url: urlString, placeholder: Util.defaultBioThumImage(), uniqueId: uniqueId)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        let drawerController = APP_DELEGATE.window?.rootViewController as? KYDrawerController
        drawerController?.setDrawerState(.closed, animated: true)
    }
    
    @IBAction func editProfileButtonAction(_ sender: Any) {
        let editProfile = UIStoryboard.getViewController(identifier: "EditProfileViewController") as! EditProfileViewController
        editProfile.editProfile = true
        editProfile.myProfile = self.myProfile
        let navController = UINavigationController.init(rootViewController: editProfile)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    func openEditProfile()
    {
        let createProfile = UIStoryboard.loadEditProfileViewController() as! EditProfileViewController
        createProfile.editProfile = true
        createProfile.myProfile = self.myProfile
        self.navigationController?.pushViewController(createProfile, animated: true)
    }
    
    @IBAction func settingButtonAction(_ sender: Any) {
        let settingViewController = UIStoryboard.getViewController(identifier: "SettingViewController")
        let navController = UINavigationController.init(rootViewController: settingViewController)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func subscribeButtonAction(_ sender: Any) {
        if !Util.getSubscribeValidityIsAvalibale() {
            openSubscriptionPage()
        }
    }
    
    fileprivate func openSubscriptionPage()
    {
        let recentViewController = UIStoryboard.getViewController(identifier: "AppPurchasePacksVC")
        self.navigationController?.pushViewController(recentViewController, animated: true)
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print(TAG + " scrollViewWillBeginDragging \(scrollContainerView.frame.height)")

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        print(TAG + " scrollViewDidScroll \(scrollContainerView.frame.height)")
        
        
        let y: CGFloat = scrollView.contentOffset.y
        let newHeaderViewHeight: CGFloat = headerViewHeightConstraint.constant - y
        
        if newHeaderViewHeight > headerMaxHeightForScroll {
            headerViewHeightConstraint.constant = headerMaxHeightForScroll//headerMaxHeight
        } else if newHeaderViewHeight < headerMinHeight {
            headerViewHeightConstraint.constant = headerMinHeight
        } else {
            headerViewHeightConstraint.constant = newHeaderViewHeight
            // scrollView.contentOffset.y = 0 // block scroll view
        }
        let ratio = headerViewHeightConstraint.constant/headerMaxHeight
        // print("ratio : \(ratio)")
        if abs(ratio) < 1
        {
            headerBlurView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: (1 - abs(ratio)))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(TAG + " scrollViewDidEndDecelerating \(scrollContainerView.frame.height)")
        checkAndReturnToActualSize()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print(TAG + " scrollViewDidEndScrollingAnimation \(scrollContainerView.frame.height)")
        checkAndReturnToActualSize()
    }
    
    func checkAndReturnToActualSize()
    {
        let y: CGFloat = scrollView.contentOffset.y
        let newHeaderViewHeight: CGFloat = headerViewHeightConstraint.constant - y
        if newHeaderViewHeight > headerMaxHeight {
            headerViewHeightConstraint.constant = headerMaxHeight
            headerBlurView.backgroundColor = UIColor.clear
        }
    }
}

extension ProfileViewController {
    private func validateSubscriptions(){
        if Util.getSubscribeValidityIsAvalibale() {
            let model = CheckSubscriptionResponse.init().getCheckSubData()
            subscribeTitleLbl.text = model?.subscription?.subscribePack?.packName
            subscribeSubTitleLbl.text = model?.subscription?.subscribePack?.description
            subscribeNowLbl.isHidden = true
            btnSubscribe.isEnabled = false
            let image = UIImage(named: "subscription_lock")
            imgSubscribeIcon.image = image
        }
    }
}



extension ProfileViewController {
    func sendOpenPageEvent(){
        AppAnalytics.log(.openScreen(screen: .myProfile))
        TPAnalytics.log(.openScreen(screen: .myProfile))
    }
}

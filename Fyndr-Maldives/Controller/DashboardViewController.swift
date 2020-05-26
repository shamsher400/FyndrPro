//
//  DashboardViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import KYDrawerController
import Alamofire
import Koloda
import pop
import XMPPFramework
import SwiftyJSON
import Firebase
import Lottie
import ListPlaceholder
import AVKit
import Crashlytics
import MessageKit
import Firebase
import Kingfisher

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 4
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1


private let pageSize = 4

enum LoadProfileRequestStatus {
    case ideal
    case inprogress
}

class DashboardViewController: UIViewController {
    

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var loaderView : UIView!
    
    @IBOutlet weak var noProfileView : UIView!
    @IBOutlet weak var messageTitle : UILabel!
    @IBOutlet weak var messageDesc : UILabel!
    @IBOutlet weak var retryBtn : UIButton!
    
    fileprivate var recentAlertIcon : UIImageView?
    fileprivate var bookmarkCount : UILabel?
    
    let cellIdentifier = "InterestFilterCollectionViewCell"
    var animationView: UIView?
    
    var currentBrowserProfiles : [Profile]?
    var queuedBrowserProfiles : [Profile]?
    var browserProfiles : BrowserProfiles?
    var currentSearchCategory = Interest.init(id: SEARCH_TYPE_DEFAULT, name: "", thumbUrl: nil)
    var browseCategory = BrowseCategory.init()
    var appVersionController = AppVersionControll.init();
    
    var loadMoreProfileRequestStatus = LoadProfileRequestStatus.ideal
    var visitedCount = 0
    var waitingToLoadMore = false
    var noProfileFound = false
    
    var myProfile : Profile?
    
    var likeCount : Int = 0 {
        didSet{
            guard let bookmarkCountLabel = bookmarkCount else {
                return
            }
            if likeCount > 0 {
                bookmarkCountLabel.isHidden = false
                bookmarkCountLabel.text = String(likeCount)
            }else {
                bookmarkCountLabel.isHidden = true
                bookmarkCountLabel.text = "0"
            }
        }
    }
    
    
    // Add intrucyion points
    let pointOfInterest = UIView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(self.loaderView)
        
        self.setupNavigationBar()
        self.hideNoProfileView()
        self.setupCollectionView()
        self.initCardView()
        
        self.browserProfiles = BrowserProfiles.init()
        print("Fyndr : init last saved profile list, count  : \(String(describing: browserProfiles?.profiles?.count))")
        print("Fyndr : show loader")
        loaderView.showLoader()
        self.loaderView.isHidden = false
        self.browseProfileRequest(isFirstRequest : true)
        // Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(hideLoader), userInfo: nil, repeats: false)
        self.retryBtn.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
    }
    
    
    @IBAction func openSubscriptionPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "subscriptionOtpVC")
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func openSubscriptionPage(){
            let recentViewController = UIStoryboard.getViewController(identifier: "AppPurchasePacksVC")
            self.navigationController?.pushViewController(recentViewController, animated: true)
    }
    
    @objc func hideLoader()
    {
        print("Fyndr : hide loader")
        loaderView.isHidden = true
        loaderView.hideLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .browseProfile))
        TPAnalytics.log(.openScreen(screen: .browseProfile))
        self.navigationController?.isNavigationBarHidden = false
        myProfile = Util.getProfile()
        verefyAppVersion()
        checkSubscriptionRequest(uniqeId: myProfile?.uniqueId ?? "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // print("Register Chat delegate : DVC")
        if ChatManager.share.isReady {
            ChatManager.share.addDelegate(delegate: self)
        }
        
        // let crashText = Int("dsjfb jsdf ")! + 1
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let browseProfileOverlayView = kolodaView.viewForCard(at: kolodaView.currentCardIndex) as? BrowseProfileOverlayView
        {
            print("Name : \(String(describing: browseProfileOverlayView.profile?.name))")
            browseProfileOverlayView.stopVideo()
        }
    }
    
    @objc func openLeftMenu()
    {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    
    @objc func recentButtonClick()
    {
        openRecentViewController()
    }
    
    func openRecentViewController() {
        recentAlertIcon?.isHidden = true
        print("DeRegister Chat delegate : DVC")
        let recentViewController = UIStoryboard.getViewController(identifier: "RecentViewController")
        self.navigationController?.pushViewController(recentViewController, animated: true)
    }
    
    
    @objc func bookmarkButtonClick()
    {
        likeCount = 0
        let bookmarkViewController = UIStoryboard.getViewController(identifier: "BookmarkViewController")
        self.navigationController?.pushViewController(bookmarkViewController, animated: true)
    }
    
    fileprivate func openChatViewController(profile : Profile?)
    {
        guard let profile = profile, let myProfile = self.myProfile else {
            return
        }
        if ChatManager.share.isReady {
            
            let chatVC = UIStoryboard.getViewController(identifier: "ChatViewController") as! ChatViewController
            chatVC.myProfile = myProfile
            chatVC.profile = profile
            self.navigationController?.pushViewController(chatVC, animated: true)
        }       
    }
    
    fileprivate func openUserDetail(profile : Profile?)
    {
        guard let profile = profile else {
            return
        }
        let userDetailViewController = UIStoryboard.getViewController(identifier: "UserDetailViewController") as! UserDetailViewController
        userDetailViewController.profile = profile
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
    }
    
    @IBAction func retryButtonAction(_ sender: Any) {
        if Reachability.isInternetConnected()
        {
            self.handleCategoryChange()
        }else {
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
}

extension DashboardViewController
{
    fileprivate func checkAndLoadMoreProfile()
    {
        print("Fyndr : check and load more profile")
        if let queuedProfiles = self.queuedBrowserProfiles
        {
            if queuedProfiles.count > 0
            {
                print("Fyndr : queue available so add in list and relaod")
                self.currentBrowserProfiles?.append(contentsOf: queuedProfiles)
                self.kolodaView.reloadData()
                
                print("Fyndr : clear queue")
                self.queuedBrowserProfiles?.removeAll()
            }
        }
        
        if let totalProfileCountInSession = self.currentBrowserProfiles?.count
        {
            let remaimingProfileCount = totalProfileCountInSession - self.visitedCount
            print("Fyndr : remaimingProfileCount : \(remaimingProfileCount)")
            
            if remaimingProfileCount >= 0 && remaimingProfileCount <= pageSize
            {
                print("Fyndr : number of profile is less then pageSize")
                
                if remaimingProfileCount == 0 {
                    print("Fyndr : no profile is available to show")
                    
                    if noProfileFound
                    {
                        print("Fyndr : show no profile view")
                        self.showNoProfileViewFor(error: false, reason: nil)
                    }else{
                        print("Fyndr : start loader and wiat")
                        loaderView.showLoader()
                        self.loaderView.isHidden = false
                        self.waitingToLoadMore = true
                    }
                }
                
                if !noProfileFound
                {
                    if loadMoreProfileRequestStatus == .ideal {
                        print("Fyndr : no request is in progress so load next profile")
                        self.browseProfileRequest(isFirstRequest: false)
                    }else{
                        print("Fyndr : next profile request is in rogress so don't do anything")
                    }
                }
            }
        }
    }
    
    fileprivate func handleCategoryChange()
    {
        print("Fyndr : Category changed, name : \(String(describing: self.currentSearchCategory.name))")
        self.noProfileFound = false
        self.hideNoProfileView()
        
        self.currentBrowserProfiles?.removeAll()
        self.queuedBrowserProfiles?.removeAll()
        self.visitedCount = 0
        self.kolodaView.resetCurrentCardIndex()
        
        // Cancel Old running browseProfile request if any
        print("Fyndr : cancel last browse request")
        RequestManager.shared.cancelBrosweRequest()
        
        if self.currentSearchCategory.id == SEARCH_TYPE_DEFAULT
        {
            if let profileList = self.browserProfiles?.profiles
            {
                print("Fyndr : load default category profile from saved list, count : \(profileList.count)")
                self.currentBrowserProfiles?.append(contentsOf: profileList)
                self.kolodaView.reloadData()
            }
        }else {
            if let profileFromBrowseProfile = self.browserProfiles?.getProfileForInterestCategory(categoryId: self.currentSearchCategory.id)
            {
                if profileFromBrowseProfile.count > 0
                {
                    print("Fyndr : load new category profile from saved list, count : \(profileFromBrowseProfile.count)")
                    self.currentBrowserProfiles?.append(contentsOf: profileFromBrowseProfile)
                    self.kolodaView.reloadData()
                }
            }
        }
        
        if self.currentBrowserProfiles != nil && (self.currentBrowserProfiles?.count)! > 0
        {
            if (self.currentBrowserProfiles?.count)! <= pageSize
            {
                print("Fyndr : request profile from server")
                self.browseProfileRequest(isFirstRequest: false)
            }
        }else{
            print("Fyndr : no saved profile for new category so show laoded, request and wait")
            self.waitingToLoadMore = true
            self.loaderView.showLoader()
            self.loaderView.isHidden = false
            self.browseProfileRequest(isFirstRequest: false)
        }
    }
    
    
    fileprivate func browseProfileRequest(isFirstRequest : Bool)
    {
        print("Fyndr : request browse profile isFirstRequest : \(isFirstRequest)")
        
        guard let searchType = currentSearchCategory.id else {
            print("Fyndr : searchType is nil")
            self.hideLoader()
            return
        }
        
        if Reachability.isInternetConnected()
        {
            loadMoreProfileRequestStatus = .inprogress
            RequestManager.shared.browseRequest(searchType:searchType , isFirst : isFirstRequest, onCompletion: { (responseJson) in
                
                print("Fyndr : received browse profile response")
                self.loadMoreProfileRequestStatus = .ideal
                
                DispatchQueue.main.async {
                    
                    let browserResponse = BrowserProfilesResponse.init(json: responseJson)
                    if browserResponse.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        print("Fyndr : browse profile request success isFirstRequest : \(isFirstRequest)")
                        if isFirstRequest
                        {
                            self.updateSearchCategoryList(browserResponse: browserResponse)
                        }
                        let profileList = browserResponse.profileList
                        if profileList != nil && (profileList?.count)! > 0
                        {
                            print("Fyndr : browse profile count : \(String(describing: (profileList?.count)))")
                            self.hideNoProfileView()
                            
                            if isFirstRequest
                            {
                                print("Fyndr : process first time request")
                                // self.browserProfiles?.initWithProfileList(profiles: profileList)
                                
                                if self.browserProfiles?.profiles != nil
                                {
                                    self.browserProfiles?.appendProfiles(profiles: profileList)
                                }else{
                                    self.browserProfiles?.initWithProfileList(profiles: profileList)
                                }
                                self.browserProfiles?.save()
                                
                                print("Fyndr : update saved profile with count : \(String(describing: self.browserProfiles?.profiles?.count))")
                                //print("Fyndr : show profile, count : \(String(describing: profileList?.count))")
                                //self.currentBrowserProfiles = profileList
                                self.currentBrowserProfiles = self.browserProfiles?.profiles
                               // self.kolodaView.reloadData()
                                self.loadFirstResponseImage(profiles: self.currentBrowserProfiles)
                            } else {
                                self.hideLoader()
                                print("Fyndr : process next request, searchType : \(searchType) self.currentSearchCategory.id : \(String(describing: self.currentSearchCategory.id))")
                                
                                if searchType == self.currentSearchCategory.id
                                {
                                    if self.waitingToLoadMore
                                    {
                                        print("Fyndr : waiting to load profile so refresh view")
                                        self.waitingToLoadMore = false
                                        self.currentBrowserProfiles?.append(contentsOf: profileList!)
                                        self.kolodaView.reloadData()
                                    }else{
                                        print("Fyndr : add response in queue")
                                        self.queuedBrowserProfiles = browserResponse.profileList
                                    }
                                }
                                // Save old data
                                self.browserProfiles?.save()
                                // Append new received profile
                                self.browserProfiles?.appendProfiles(profiles: profileList)
                                print("Fyndr : append in saved profile, now total count : \(String(describing: self.browserProfiles?.profiles?.count))")
                                // Save new updated list
                                self.browserProfiles?.save()
                            }
                            DownloadManager.shared.downloadVideoForProfiles(profiles: profileList!)
                            
                        }else{
                            self.hideLoader()
                            let savedProfiles =  self.browserProfiles?.profiles
                            if savedProfiles != nil && (savedProfiles?.count)! > 0
                            {
                                if self.currentBrowserProfiles == nil
                                {
                                    print("Fyndr : load saved profile 1st time, count \(String(describing: savedProfiles?.count))")
                                    self.currentBrowserProfiles = savedProfiles
                                    self.kolodaView.reloadData()
                                }
                            }else{
                            
                                self.noProfileFound = true
                                print("Fyndr : No profile found, isFirstRequest : \(isFirstRequest) waitingToLoadMore :\(self.waitingToLoadMore)")
                                // No profile found
                                if isFirstRequest || self.waitingToLoadMore
                                {
                                    self.showNoProfileViewFor(error : false, reason :browserResponse.reason)
                                }
                            }
                        }
                    }else {
                        self.hideLoader()
                        print("Fyndr : browse profile request failed with reason : \(String(describing: browserResponse.reason))")
                        self.handleFailedResponse(isFirstRequest: isFirstRequest, reason: browserResponse.reason)
                    }
                }
            }) { (error) in
                print("Fyndr : error in browse profile : \(String(describing: error?.localizedDescription))")
                
                DispatchQueue.main.async {
                    self.hideLoader()
                    self.loadMoreProfileRequestStatus = .ideal
                    
                    let code = error?.localizedDescription ?? ""
                    if code != "cancelled"
                    {
                        self.handleFailedResponse(isFirstRequest: isFirstRequest, reason: nil)
                    }
                }
            }
        }else {
            print("Fyndr : not connected to internet")
            self.hideLoader()
            self.loadMoreProfileRequestStatus = .ideal
            self.handleFailedResponse(isFirstRequest: isFirstRequest, reason: nil)
        }
    }
    
    fileprivate func handleFailedResponse(isFirstRequest : Bool, reason : String?)
    {
        if isFirstRequest
        {
            let savedProfiles =  browserProfiles?.profiles
            
            if savedProfiles != nil && (savedProfiles?.count)! > 0
            {
                print("Fyndr : load saved profile 1st time, count \(String(describing: savedProfiles?.count))")
                self.currentBrowserProfiles = savedProfiles
                self.kolodaView.reloadData()
                
            } else if reason != nil {
                print("Fyndr : Error reason : \(String(describing: reason))")
                self.showNoProfileViewFor(error : true, reason :reason)
            }else {
                print("Fyndr : Error generic error")
                self.showNoProfileViewFor(error : true, reason :nil)
            }
        } else {
            if self.waitingToLoadMore
            {
                self.waitingToLoadMore = false
                if reason != nil {
                    print("Fyndr : Error reason : \(String(describing: reason))")
                    self.showNoProfileViewFor(error : true, reason :reason)
                }else {
                    print("Fyndr : Error generic error")
                    self.showNoProfileViewFor(error : true, reason :nil)
                }
            }
        }
    }
    
    fileprivate func updateSearchCategoryList(browserResponse : BrowserProfilesResponse)
    {
        print("Fyndr : update search category list and reload")
        self.browseCategory.initWithCategoryList(categories: browserResponse.categoryList)
        self.browseCategory.save()
        self.collectionView.reloadData()
    }
}


extension DashboardViewController : KolodaViewDelegate, KolodaViewDataSource
{
    fileprivate func initCardView()
    {
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.appearanceAnimationDuration = 1
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return self.currentBrowserProfiles?.count ?? 0
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let browseProfileOverlayView : BrowseProfileOverlayView = UIView.fromNib()
        browseProfileOverlayView.delegate = self
        browseProfileOverlayView.collectionViewHeight = self.collectionViewHeightConstraint.constant
        browseProfileOverlayView.myProfile = myProfile
        browseProfileOverlayView.profile = self.currentBrowserProfiles?[index]
        
        browseProfileOverlayView.chatButtonPressed = { profile in
            print("Fyndr : profileId : \(String(describing: profile?.uniqueId))")
            self.openChatViewController(profile: profile)
        }
        browseProfileOverlayView.profileDetailButtonPressed = { profile in
            print("Fyndr : profileId : \(String(describing: profile?.uniqueId))")
            self.openUserDetail(profile : profile)
        }
        browseProfileOverlayView.profileImageClick = { profile in
            self.openUserDetail(profile : profile)
        }        
        return browseProfileOverlayView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("ProfileOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection]
    {
        return [.left, .right,.up, .down]
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool
    {
        let browseProfileOverlayView = koloda.viewForCard(at: index) as? BrowseProfileOverlayView
        browseProfileOverlayView?.stopVideo()
        
        if (direction == .up )
        {
            browseProfileOverlayView?.updatePage()
            return false
        }
        else if (direction == .down) {
            return false
        }
        return true
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection)
    {
        print("Fyndr : didSwipeCardAt : index \(index) SwipeResultDirection : \(direction) countOfCards : \(koloda.countOfCards)")
        //pauseVideo(koloda: koloda)
        if let profile = self.currentBrowserProfiles?[index]
        {
            if (direction == .up || direction == .down) {
            }else if direction == .left{
                self.handleProfileSwipe(right: false, profile : profile)
            }else if direction == .right{
                self.handleProfileSwipe(right: true, profile : profile)
            }
        }
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.2
    }
    
    func pauseVideo(koloda : KolodaView)
    {
        /*
         koloda.layer.sublayers?.forEach {
         if $0.isKind(of: AVPlayerLayer.self)
         {
         ($0 as? AVPlayerLayer)?.player?.pause()
         }
         // $0.removeFromSuperlayer()
         }
         */
    }
    
    
    func handleProfileSwipe(right : Bool, profile : Profile)
    {
        self.visitedCount = self.visitedCount  + 1
        print("Fyndr : delate profile from saved list")
        self.browserProfiles?.deleteProfile(profile: profile)
        self.browserProfiles?.save()
        print("Fyndr : profile count after delete : \(String(describing: self.browserProfiles?.profiles?.count))")
        checkAndLoadMoreProfile()
        if right
        {
            self.likeCount = self.likeCount + 1
            print("Fyndr : Add profile to bookmark list")
            BookmarkManager.shared.addToBookmark(profile: profile)
            sendBookmarkEvents(isBookMark: true, profile: profile)
        }else{
            DownloadManager.shared.discardVideo(profile: profile)
            sendBookmarkEvents(isBookMark: false, profile: profile)
        }
    }
}

extension DashboardViewController : UICollectionViewDelegate, UICollectionViewDataSource
{
    
    fileprivate func setupCollectionView()
    {
        let itemHeight = SCREEN_HEIGHT/10 > 80 ? 80 : SCREEN_HEIGHT/10
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: itemHeight , height: itemHeight + 10)
        flowLayout.minimumLineSpacing = 5
        
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionViewHeightConstraint.constant = itemHeight + 20
        self.filterViewHeightConstraint.constant = itemHeight + 20 + 4
        self.topMarginConstraint.constant = itemHeight + 20 + 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.browseCategory.categories.count > 0
        {
            return self.browseCategory.categories.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let interestFilterCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! InterestFilterCollectionViewCell
        interestFilterCell.myProfile = self.myProfile
        
        if self.browseCategory.categories.count > indexPath.row
        {
            let interest = self.browseCategory.categories[indexPath.row]
            interestFilterCell.interest = interest
            
            if interest.id == currentSearchCategory.id
            {
                interestFilterCell.selectedInterest = true
            }else{
                interestFilterCell.selectedInterest = false
            }
        }else{
            let interest = Interest.init(id: SEARCH_TYPE_DEFAULT, name: "", thumbUrl: nil)
            interestFilterCell.interest = interest
            interestFilterCell.selectedInterest = false
        }
        return interestFilterCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let interestFilterCell =  collectionView.cellForItem(at: indexPath) as! InterestFilterCollectionViewCell
        
        if self.browseCategory.categories.count > indexPath.row
        {
            let interest = self.browseCategory.categories[indexPath.row]
            
            if !interestFilterCell.selectedInterest
            {
                interestFilterCell.selectedInterest = !interestFilterCell.selectedInterest
                currentSearchCategory = interest
                self.sendChangeInterestAnalytics(interestId: interest.id)
                self.collectionView.reloadData()
                self.handleCategoryChange()
            }
        }
    }
}


extension DashboardViewController : ChatManagerDelegate
{
    func didSendMessage() {
        
    }
    
    
    
    func didFailedMessage(mxppMessage: String, error: Error) {
        print("Chat send failed ")
    }
    
    func didReceiveMessage(chat : ChatModel, sender : Sender)
    {
        recentAlertIcon?.isHidden = false
    }
}

extension DashboardViewController
{
    fileprivate func showNoProfileViewFor(error : Bool, reason : String?)
    {
        print("Fyndr : show no profile view error : \(error) reason : \(String(describing: reason))")
        
        if error
        {
            self.retryBtn.isHidden = false
            self.messageTitle.text = NSLocalizedString("Oops!", comment: "")
            if reason != nil
            {
                self.messageDesc.text = reason!
            }else{
                self.messageDesc.text = NSLocalizedString("M_UNABLE_TO_LOAD_PROFILE_PLEASE_TRY_AGAIN", comment: "")
            }
        }else{
            self.retryBtn.isHidden = true
            self.messageTitle.text = NSLocalizedString("ALL_PROFILE_VIWED", comment: "")
            if reason != nil
            {
                self.messageDesc.text = reason!
            }else{
                self.messageDesc.text = NSLocalizedString("COME_BACK_SOON_TO_FIND_MORE_PROFRILE_TO_CONNECT_WITH", comment: "")
            }
        }
        self.noProfileView.isHidden = false
    }
    
    fileprivate func hideNoProfileView()
    {
        print("Fyndr : hide no profile view")
        self.noProfileView.isHidden = true
    }
}

extension DashboardViewController
{
    fileprivate func setupNavigationBar()
    {
        let menuBtn = UIButton.init(type: .custom)
        menuBtn.setImage(UIImage(named: "drawer_user"), for: .normal)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        menuBtn.backgroundColor = UIColor.clear
        menuBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
        menuBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
        menuBtn.addTarget(self, action: #selector(openLeftMenu), for: UIControl.Event.touchUpInside)
        //menuBtn.setTitle("Fyndr", for: .normal)
        menuBtn.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: UIFont.Weight.medium)
        menuBtn.contentHorizontalAlignment = .left
        let menuBarButton = UIBarButtonItem(customView: menuBtn)
        self.navigationItem.leftBarButtonItem = menuBarButton
        self.title = Util.appName().uppercased()
        
        
        let recentView = UIView.init()
        recentView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH * 0.09, height: SCREEN_WIDTH * 0.09)
        recentView.backgroundColor = UIColor.clear
        
        let recentBtn = UIButton.init(type: .custom)
        recentBtn.frame = recentView.bounds
        recentBtn.setImage(UIImage(named: "chat_notify"), for: UIControl.State.normal)
        recentBtn.addTarget(self, action: #selector(recentButtonClick), for: UIControl.Event.touchUpInside)
        recentBtn.backgroundColor = UIColor.clear
        
        recentAlertIcon = UIImageView.init()
        recentAlertIcon?.frame = CGRect(x: recentBtn.frame.origin.x + recentBtn.frame.size.width - 10 , y: 5, width: 10, height: 10)
        //recentAlertIcon?.image = UIImage.init(named: "notificationbadge")
        recentAlertIcon?.backgroundColor = UIColor.bookmarkBadgeColor
        recentAlertIcon?.layer.cornerRadius =  (recentAlertIcon!.frame.width)/2
        recentAlertIcon?.layer.masksToBounds = true
        recentAlertIcon?.isHidden = true
        recentView.addSubview(recentBtn)
        recentView.addSubview(recentAlertIcon!)
        
        
        let bookmarkView = UIView.init()
        bookmarkView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH * 0.1, height: SCREEN_WIDTH * 0.1)
        bookmarkView.backgroundColor = UIColor.clear
        
        let bookmarkBtn = UIButton.init(type: .custom)
        bookmarkBtn.frame = bookmarkView.bounds
        bookmarkBtn.setImage(UIImage(named: "bookmark_white"), for: UIControl.State.normal)
        bookmarkBtn.addTarget(self, action: #selector(bookmarkButtonClick), for: UIControl.Event.touchUpInside)
        bookmarkBtn.backgroundColor = UIColor.clear
        bookmarkView.addSubview(bookmarkBtn)
        
        
        bookmarkCount = UILabel.init()
        bookmarkCount?.frame = CGRect(x: bookmarkBtn.frame.origin.x + bookmarkBtn.frame.size.width - 10 , y: 0, width: 15, height: 15)
        bookmarkCount?.backgroundColor = UIColor.bookmarkBadgeColor
        bookmarkCount?.textColor = UIColor.appPrimaryColor
        bookmarkCount?.font = UIFont.systemFont(ofSize: 13)
        bookmarkCount?.textAlignment = .center
        bookmarkCount?.layer.cornerRadius =  (bookmarkCount!.frame.width)/2
        bookmarkCount?.layer.masksToBounds = true
        bookmarkCount?.adjustsFontSizeToFitWidth = true
        bookmarkCount?.isHidden = true
        bookmarkView.addSubview(bookmarkCount!)
        
        let recentBarButton = UIBarButtonItem(customView: recentView)
        let bookmarkBarButton = UIBarButtonItem(customView: bookmarkView)
        
        self.navigationItem.rightBarButtonItems = [recentBarButton,bookmarkBarButton]
    }
}


extension DashboardViewController : BrowseProfileOverlayViewDelegate
{
    func playView(fileUrl: URL) {
        let videoPreviewViewController = UIStoryboard.getViewController(identifier: "VideoPreviewViewController") as! VideoPreviewViewController
        videoPreviewViewController.profile = myProfile
        videoPreviewViewController.videoURL = fileUrl
        videoPreviewViewController.modalPresentationStyle = .fullScreen
        self.present(videoPreviewViewController, animated: true, completion: nil)
    }
}


// Check app version available
extension DashboardViewController {
    
    
    
    
    private func verefyAppVersion ()
    {
        if let appVersionModel = appVersionController.getVersionInfo(){
            if appVersionModel.appUpdateAction == AppVersionAction.FORCEUPDATE.rawValue {
                showAupdateAlert(versionModel: appVersionModel)
            }else if appVersionModel.appUpdateAction == AppVersionAction.SKIPUPDATE.rawValue && appVersionModel.isUpdateSkiped == false{
                showAupdateAlert(versionModel: appVersionModel)
            }
        }
    }
    
    func appUpdateAvailable(versionModel: AppVersionControll){
        let storeInfoURL: String = "http://itunes.apple.com/lookup?bundleId=com.fyndr.mmr"
        let bundle = Bundle.main
        if let infoDictionary = bundle.infoDictionary {
            let urlOnAppStore = NSURL(string: storeInfoURL)
            if let dataInJSON = NSData(contentsOf: urlOnAppStore! as URL) {
                if let dict: NSDictionary = try! JSONSerialization.jsonObject(with: dataInJSON as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject] as NSDictionary? {
                    if let results:NSArray = dict["results"] as? NSArray {
                        if let version = (results[0] as AnyObject)["version"] as? String {
                            if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                                print("\(version)")
                                if version != currentVersion {
                                    showAupdateAlert(versionModel: versionModel)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showAupdateAlert(versionModel: AppVersionControll){
        
        let alert = UIAlertController(title: versionModel.titleMessage, message: versionModel.updateMessage, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: versionModel.primaryButtonText, style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
//            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1467324861"),
//                UIApplication.shared.canOpenURL(url){
//                UIApplication.shared.openURL(url)
//            }
//
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1483587501") {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:],completionHandler: {(success) in})
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            //Cancel Action
        }))
        if versionModel.appUpdateAction == AppVersionAction.SKIPUPDATE.rawValue && versionModel.secondaryButtonText != "" {
            alert.addAction(UIAlertAction(title: versionModel.secondaryButtonText, style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
                self.appVersionController.isUpdateSkiped = true
                self.appVersionController.save()
            }))
        }
        alert.modalPresentationStyle = .fullScreen
        self.present(alert, animated: true, completion: nil)
    }
}

extension DashboardViewController {
    
    private func sendBookmarkEvents(isBookMark: Bool, profile: Profile){
        if let uniqueId = profile.uniqueId {
            
            if isBookMark {
                AppAnalytics.log(.bookmark(uniqueid: uniqueId, action: "true"))
                TPAnalytics.log(.bookmark(uniqueid: uniqueId, action: "true"))
                
            }else {
                AppAnalytics.log(.discard(uniqueid: uniqueId))
                TPAnalytics.log(.discard(uniqueid: uniqueId))
            }
        }
    }
    private func sendChangeInterestAnalytics(interestId: String?){
        if let interestIds = interestId {
            AppAnalytics.log(.browseFilter(categoryId: interestIds))
            TPAnalytics.log(.browseFilter(categoryId: interestIds ))
            
        }
    }
}


// Load First Image Before shiwing list
extension DashboardViewController {
    
    private func loadFirstResponseImage (profiles: [Profile]?){
        if let profiles = profiles {
            DownloadManager.shared.loadImageFromWithoutUi(profiles: profiles) { (success, error) in
                self.hideLoader()
                self.kolodaView.reloadData()
            }
        }else {
            self.hideLoader()
            self.kolodaView.reloadData()

        }
    }
}



// Check Subscription Flow
extension DashboardViewController {
    
    private func checkSubscriptionRequest (uniqeId: String) {
        if Reachability.isInternetConnected(){
            RequestManager.shared.checkSubscription(unique: uniqeId, onCompletion: { (response) in
               // print("Fyndr :checkSubscriptionResponse - \(response)")
                let checkSubModel = CheckSubscriptionResponse.init(json: response)
                if checkSubModel.status?.lowercased() == "success" {
                    if checkSubModel.subscription?.statusStatus ?? false {
                        var pendingSubscription = PendingPackModel.init()
                        pendingSubscription = pendingSubscription.getPendingPackModel() ?? PendingPackModel()
                        pendingSubscription.orderId = ""
                        pendingSubscription.packId = ""
                        pendingSubscription.save()
                    }else {
                        var pendingSubscription = PendingPackModel.init()
                        pendingSubscription = pendingSubscription.getPendingPackModel() ?? PendingPackModel()
                        if pendingSubscription.orderId != ""{
                            pendingSubscription.packId = ""
                            pendingSubscription.orderId = ""
                            pendingSubscription.save()
                        }
                    }
                    checkSubModel.save()
                }
            })
            { (error) in
                print("DashboardViewController: checkSubscriptionRequest() - error: \(String(describing: error?.localizedDescription))")
            }
        }else {
            print("Fyndr :checkSubscriptionRequest - not connected to internet")
        }

    }
    
}

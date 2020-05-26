//
//  UserDetailViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 20/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import DropDown
import AVKit
import Kingfisher

class UserDetailViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView : DynamicHeightCollectionView!
    
    @IBOutlet weak var scrollView: DynamicHeightScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var verticalScrollView: UIScrollView!
    
    @IBOutlet weak var aboutMeTitleLbl: UILabel!
    @IBOutlet weak var aboutMeDescLbl: UILabel!
    @IBOutlet weak var aboutMeDiv: UIView!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var mutualInterest : UILabel!
    
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMarginScrollView: NSLayoutConstraint!
    @IBOutlet weak var topMarginAbout: NSLayoutConstraint!

    fileprivate let menuDropDown = DropDown()
    fileprivate var menuButton : UIButton?
    
    fileprivate var interestList = [SubCategory]()
    fileprivate var mutualInterestList = [SubCategory]()
    fileprivate var allInterestList = [SubCategory]()
    
    var profile: Profile?
    var myProfile: Profile?
    var chatHistory : ChatHistory?
    
    var isFav = false
    var isBlocked = false
    var resourceList = [Any]()
    
    fileprivate var avPlayer: AVPlayer?
    fileprivate var avPlayerLayer : AVPlayerLayer?
    fileprivate var playVideoBtn : UIButton?
    
    var videoURL : URL!
    var updateProfile = false
    var fromChatPage = false
    
    var headerMaxHeight: CGFloat = 300
    var headerMaxHeightForScroll: CGFloat = 300
    var scrollingPageIndex = 0
    
    var updateHeightOfScrollView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLbl.font = UIFont.autoScale(weight: .medium, size: 23)
        self.cityLbl.font = UIFont.autoScale(weight: .regular, size: 15)
        
        self.aboutMeTitleLbl.font = UIFont.autoScale(weight: .medium, size: 17)
        self.aboutMeDescLbl.font = UIFont.autoScale(weight: .regular, size: 15)
        
        self.mutualInterest.font = UIFont.autoScale(weight: .medium, size: 17)
        self.mutualInterest.text = NSLocalizedString("M_MUTUAL_INTEREST", comment: "")
        
        if !updateProfile {
            self.favBtn.isHidden = true
        }        
        headerMaxHeight = SCREEN_WIDTH * 5/4
        headerMaxHeightForScroll = headerMaxHeight
        
        //self.setupNavigationBar()
        //self.setupMenuDropDown()
        
        self.setupCollectionView()
        
        self.myProfile = Util.getProfile()
        self.containerView.isHidden = true
        
        guard let myProfile = self.myProfile else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if self.profile == nil && self.chatHistory?.uniqueId == nil
        {
            self.navigationController?.popViewController(animated: true)
        }
        
        if self.profile == nil
        {
            if let uniqueId = self.chatHistory?.uniqueId {
                self.profile = DatabaseManager.shared.getProfile(uniqueId: uniqueId)
            }
        }
        
        if self.profile == nil && self.chatHistory?.uniqueId != nil
        {
            self.getPorofileDetailsFromServer(uniqueId: (self.chatHistory?.uniqueId)!, bloacking: true)
        }else{
            // If coming from saved list update porfile from server
            if let uniqueId = self.profile?.uniqueId
            {
                if updateProfile {
                    self.getPorofileDetailsFromServer(uniqueId: uniqueId, bloacking: false)
                }
            }
            loadDataInView()
            configureScrollView()
            configurePageControl()
        }
        self.mutualInterestList = myProfile.interests ?? [SubCategory]()
        self.allInterestList = Util.getInterestList()?.subCategories ?? [SubCategory]()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        headerViewHeightConstraint.constant = headerMaxHeight
        topMarginScrollView.constant = headerMaxHeight - 20
        
        verticalScrollView.contentOffset.y = 0
        AppAnalytics.log(.openScreen(screen: .userProfileDetails))
        TPAnalytics.log(.openScreen(screen: .userProfileDetails))
        
        openProfileAnalytics(profileStatus: .open)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        openProfileAnalytics(profileStatus: .close)
    }
    fileprivate func loadDataInView()
    {
        self.title = self.profile?.name
        self.containerView.isHidden = false
        setUIValues()
        self.collectionView.reloadData()
    }
    
    fileprivate func getPorofileDetailsFromServer(uniqueId : String, bloacking : Bool) {
        if bloacking {
            Util.showLoader()
            if !Reachability.isInternetConnected()
            {
                AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
                Util.hideLoader()
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        //Call profile details API
        RequestManager.shared.getProfileRequest(uniqueId: uniqueId, onCompletion: { (responseJson) in
            DispatchQueue.main.async {
                
                Util.hideLoader()
                let response =  GetProfileResponse.init(json: responseJson)
                if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                {
                    if let newProfile = response.profile
                    {
                        
                        self.profile = newProfile
                        DatabaseManager.shared.saveUpdateProfile(profile: newProfile)
                        self.loadDataInView()
                        
                        if bloacking
                        {
                            self.updateChatHistory()
                            self.configureScrollView()
                            self.configurePageControl()
                        }
                    }else{
                        if bloacking {
                            AlertView().showNotficationMessage(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }else {
                    if response.isDeleted != nil && response.isDeleted == true{
                        let alertView  = AlertView()
                        alertView.delegate = self
                        if let reason = response.reason {
                            alertView.showAlert(vc: self, title: "", message: reason, okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
                        }else {
                            alertView.showAlert(vc: self, title: "", message: NSLocalizedString("M_PROFILE_DELETED", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
                        }
                    }
                    if bloacking {
                        AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                if bloacking {
                    Util.hideLoader()
                    AlertView().showNotficationMessage(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    fileprivate func updateChatHistory()
    {
        if self.chatHistory != nil && self.profile != nil
        {
            self.chatHistory?.name = self.profile?.name
            self.chatHistory?.avatarUrl = self.profile?.imageList?.first?.url
            DatabaseManager.shared.saveUpdateChatHistory(chatHistory: self.chatHistory!)
        }
    }
    
    fileprivate func setUIValues()
    {
        self.nameLbl.text =  profile?.name
        
        let about = profile?.about
        if about != nil && (about?.count)! > 1 {
            self.aboutMeDescLbl.text = about
            self.aboutMeTitleLbl.text = NSLocalizedString("M_ABOUT_ME", comment: "")
            self.aboutMeDiv.isHidden = false
        }else{
            self.aboutMeTitleLbl.text = ""
            self.aboutMeDescLbl.text = ""
            self.aboutMeDiv.isHidden = true
            self.topMarginAbout.constant = -25
        }
        
        self.cityLbl.text = profile?.city?.name
        self.callBtn.isHidden = true
        guard let profile = self.profile else {
            return
        }
        if profile.contactNumber != nil &&  (profile.contactNumber?.count)! > 0 {
            self.callBtn.isHidden = false
        }
        
        self.isFav = DatabaseManager.shared.isBookmarked(uniqueId: profile.uniqueId)
        self.isBlocked = DatabaseManager.shared.isBlocked(uniqueId: profile.uniqueId)
        self.favBtn.isSelected = self.isFav
        
        if let interests =  profile.interests
        {
            self.mutualInterest.isHidden = false
            self.interestList = interests
        }else{
            self.mutualInterest.isHidden = true
            self.interestList = [SubCategory]()
        }
        
        resourceList.removeAll()
        if let imageModel = profile.imageList?.first
        {
            resourceList.append(imageModel)
        }
        if let videoModel = profile.videoList?.first
        {
            resourceList.append(videoModel)
        }
    }
    
    @IBAction func chatButtonAction(_ sender: Any) {
        
        if fromChatPage
        {
            self.navigationController?.popViewController(animated: true)
        }else{
            
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
    }
    
    @IBAction func callButtonAction(_ sender: Any) {
        _ = CallHandler.initiateCall(profile: profile, chatHistory: self.chatHistory)
    }
    
    @IBAction func favButtonAction(_ sender: Any) {
        self.addDeleteBookmarkProfile()
        sendAddDeleteAnalytics()
    }
    
    
    @IBAction func menuButtonAction(_ sender: Any) {
        self.pauseVideo()
        self.showOptionMenu()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        guard let _ = navigationController?.popViewController(animated: true) else
        {
            dismiss(animated: true, completion: nil)
            return
        }
    }
}

extension UserDetailViewController {

    // MARK: Custom method implementation
    func configureScrollView() {
        
        let width = SCREEN_WIDTH
        scrollView.isPagingEnabled = true
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height:headerMaxHeight)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(resourceList.count), height: scrollView.frame.size.height)
        
        
        scrollView.contentInset = UIEdgeInsets.zero;
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero;
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        
        
        for i in 0..<resourceList.count {
            
            let containerView = UIView.init()
            containerView.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: scrollView.frame.origin.y, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            let imageView = UIImageView.init()
            imageView.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
            imageView.contentMode = .scaleAspectFill
            containerView.clipsToBounds = true
            containerView.addSubview(imageView)
            
            
            scrollView.backgroundColor = UIColor.blue
            imageView.backgroundColor = UIColor.yellow
            containerView.backgroundColor = UIColor.red
            
            
            
            scrollView.addSubview(containerView)
            
            
            
            let resource = resourceList[i]
            //var resourceUrlString : String?
            
            if let myProfile = myProfile , let uniqueId = myProfile.uniqueId
            {
                if (resource as AnyObject) is ImageModel
                {
                    let imageObj = resource as! ImageModel
                    //resourceUrlString = imageObj.url
                    if let urlString = imageObj.url {
                        imageView.setKfImage(url: urlString, placeholder: Util.defaultBioThumImage(), uniqueId: uniqueId)
                    }
                }else {
                    let videoObj = resource as! VideoModel
                    //resourceUrlString = videoObj.thumbUrl
                    containerView.backgroundColor = UIColor.black
                    
                    // Set Video
                    if let urlString = videoObj.url
                    {
                        let fileManager = AppFileManager.init()
                        if let fileName = urlString.components(separatedBy: "/").last
                        {
                            let localFilePath = fileManager.filePath(fileNameWithExtension: "\(fileName).mp4")
                            
                            if !fileManager.isFileExistAt(path: localFilePath)
                            {
                                // Download and save video file in local
                                guard let uniqueId = self.myProfile?.uniqueId else{
                                    return
                                }
                                var urlString = "\(urlString)?deviceId=\(Util.deviceId())&userId=\(uniqueId)&type=download"
                                if PUBLIC_IP {
                                    urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
                                }
                                
                                RequestManager.shared.downloadRequest(url: urlString,destinationUrl :localFilePath, onCompletion: { (response) in
                                    print("response : \(response)")
                                    
                                    if fileManager.isFileExistAt(path: localFilePath)
                                    {
                                        DispatchQueue.main.async {
                                            self.initPlayerViewWithLocalUrl(containerView: containerView, videoUrl: localFilePath)
                                        }
                                    }
                                }, onFailure: { (error) in
                                    print("error : \(String(describing: error?.localizedDescription))")
                                }) { (progress) in
                                    // print("progress :\(String(describing: progress?.completedUnitCount))")
                                }
                            }else{
                                self.initPlayerViewWithLocalUrl(containerView: containerView, videoUrl: localFilePath)
                            }
                        }
                    }
                    
                    
                    if let urlString = videoObj.thumbUrl {
                        
                        imageView.setKfImage(url: urlString, placeholder: Util.defaultBioThumImage(), uniqueId: uniqueId)
                    }
                }
            }
        }
    }
    
    func configurePageControl() {
        pageControl.numberOfPages = resourceList.count
        pageControl.currentPage = 0
        verifyScrollObjects(scrollIndex: pageControl.currentPage)
    }
    
    // MARK: page change
    @IBAction func changePage(_ sender: AnyObject) {
        var newFrame = scrollView.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl.currentPage)
        scrollView.scrollRectToVisible(newFrame, animated: true)
        verifyScrollObjects(scrollIndex: pageControl.currentPage)
    }
}


extension UserDetailViewController
{
    fileprivate func setupNavigationBar()
    {
        menuButton = UIButton.init(type: .custom)
        menuButton?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        //menuButton?.setImage(UIImage(named: "more-horizontal"), for: UIControl.State.normal)
        menuButton?.setImage(UIImage(named: "more-vertical"), for: UIControl.State.normal)
        menuButton?.addTarget(self, action: #selector(menuButtonClick), for: UIControl.Event.touchUpInside)
        menuButton?.backgroundColor = UIColor.clear
        menuButton?.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -20)
        let menuBarButton = UIBarButtonItem(customView: menuButton!)
        self.navigationItem.rightBarButtonItem = menuBarButton
    }
    
    @objc func menuButtonClick()
    {
        updateMenuDataSource()
        menuDropDown.show()
    }
    
    func setupMenuDropDown() {
        
        menuDropDown.anchorView = self.menuButton
        menuDropDown.width = 200
        menuDropDown.bottomOffset = CGPoint(x: 0, y: 40)
        menuDropDown.cellHeight = SCREEN_HEIGHT/8 > 60 ? 60 : SCREEN_HEIGHT/8
        menuDropDown.backgroundColor = UIColor.white
        
        menuDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            cell.optionLabel.text = item
        }
        // Action triggered on selection
        menuDropDown.selectionAction = { [unowned self] (index, item) in
            if index == 0 // Block
            {
                self.blockUnblockProfile()
                self.userBlockAnalytics()
            }else {
                // report
                self.reportProfile()
            }
        }
    }
    
    func updateMenuDataSource()
    {
        var menuItem = [String]()
        if self.isBlocked
        {
            menuItem.append(NSLocalizedString("M_UN_BLOCK", comment: ""))
        }else{
            menuItem.append(NSLocalizedString("M_BLOCK", comment: ""))
        }
        menuItem.append(NSLocalizedString("M_REPOER", comment: ""))
        menuDropDown.dataSource = menuItem
    }
    
    
    
    fileprivate func showOptionMenu()
    {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var blockOption = NSLocalizedString("M_BLOCK", comment: "")
        if self.isBlocked
        {
            blockOption = NSLocalizedString("M_UN_BLOCK", comment: "")
        }
        
        let blockUnblock = UIAlertAction(title: blockOption, style: .default){ (action) in
            // Block un block
            self.blockUnblockProfile()
            self.userBlockAnalytics()
        }
        optionMenu.addAction(blockUnblock)
        
        
        let report = UIAlertAction(title: NSLocalizedString("M_REPOER", comment: ""), style: .default){ (action) in
            self.reportProfile()
        }
        optionMenu.addAction(report)
        
        let cancel = UIAlertAction(title: NSLocalizedString("M_CANCEL", comment: ""), style: .cancel){ (action) in
        }
        optionMenu.addAction(cancel)
        optionMenu.modalPresentationStyle = .fullScreen
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    fileprivate func blockUnblockProfile()
    {
        guard let profile = self.profile, let uniqueId = profile.uniqueId else {
            return
        }
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            
            if self.isBlocked {
                RequestManager.shared.deleteBlockListRequest(blockListIds: [BlockIds.init(uniqueId: uniqueId)], onCompletion: { (responseJson) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        
                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            self.isBlocked = !self.isBlocked
                            DatabaseManager.shared.deteleFromBlockList(uniqueId: uniqueId)
                            AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_REQUEST_SUCCESS", comment: ""))
                        }else {
                            AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                        }
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        AlertView().showNotficationMessage(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }else {

                RequestManager.shared.addBlockListRequest(blockListIds: [BlockIds.init(uniqueId: uniqueId)], onCompletion:{ (responseJson) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        
                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            self.isBlocked = !self.isBlocked
                            DatabaseManager.shared.saveUpdateBlockList(profiles: [profile],blockIds :[BlockIds.init(uniqueId: uniqueId)])
                            AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_REQUEST_SUCCESS", comment: ""))
                        }else {
                            AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                        }
                    }
                    
                }) { (error) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        AlertView().showNotficationMessage(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }
        }else {
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    
    fileprivate func addDeleteBookmarkProfile()
    {
        guard let profile = self.profile, let uniqueId = profile.uniqueId else {
            return
        }
        
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            if self.favBtn.isSelected
            {
                RequestManager.shared.deleteBookmarkRequest(bookmarkIds : [BookmarkIds.init(uniqueId: uniqueId)], onCompletion: { (responseJson) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        
                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            self.favBtn.isSelected = !self.favBtn.isSelected
                            DatabaseManager.shared.deleteBookmark(uniqueId: uniqueId)
                            AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_REQUEST_SUCCESS", comment: ""))
                        }else {
                            AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                        }
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        AlertView().showNotficationMessage(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }else{
                RequestManager.shared.addBookmarkRequest(bookmarkIds: [BookmarkIds.init(uniqueId: uniqueId)], onCompletion:{ (responseJson) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        
                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            self.favBtn.isSelected = !self.favBtn.isSelected
                            DatabaseManager.shared.saveUpdateBookmark(profiles: [profile], bookmarkIds : [BookmarkIds.init(uniqueId: profile.uniqueId)])
                            AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_REQUEST_SUCCESS", comment: ""))
                        }else {
                            AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                        }
                    }
                    
                }) { (error) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        AlertView().showNotficationMessage(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }
        }else {
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    fileprivate func reportProfile()
    {
        let reportViewController = UIStoryboard.getViewController(identifier: "ReportViewController") as! ReportViewController
        reportViewController.profile = self.profile
        reportViewController.chatHistory = self.chatHistory
        self.navigationController?.pushViewController(reportViewController, animated: true)
    }
}


extension UserDetailViewController: AVAudioPlayerDelegate
{
    
    func initPlayerViewWithLocalUrl(containerView : UIView, videoUrl : String)
    {
        let item = AVPlayerItem(url: URL(fileURLWithPath: videoUrl))
        self.avPlayer = AVPlayer(playerItem: item)
        self.avPlayer?.actionAtItemEnd = .none
        
        self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        self.avPlayerLayer?.videoGravity = .resizeAspectFill
        self.avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
        
        containerView.layer.addSublayer(self.avPlayerLayer!)
        
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
            } else {
            }
        } catch let error as NSError {
            print(error)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        // Allow background audio to continue to play
        playVideoBtn = UIButton.init(frame: CGRect(x: (containerView.frame.size.width - 60)/2, y: (containerView.frame.size.height - 60)/2, width: 60, height: 60))
        playVideoBtn?.addTarget(self, action: #selector(startVideo), for: .touchUpInside)
        playVideoBtn?.setImage(UIImage.init(named: "video_play"), for: .normal)
        containerView.addSubview(playVideoBtn!)
        
        let tabGesture = UITapGestureRecognizer.init(target: self, action: #selector(playPauseAction))
        containerView.addGestureRecognizer(tabGesture)
        containerView.backgroundColor = UIColor.black
    }
    
    func playVideo(){
        guard let palyer = avPlayer else {
            return
        }
        self.playVideoBtn?.isHidden = true
        palyer.play()
        self.sendVideoActionAnalytics(videoStatus: .play)
        
    }
    
    func pauseVideo(){
        
        guard let palyer = avPlayer else {
            return
        }
        self.playVideoBtn?.isHidden = false
        
        if palyer.rate != 0
        {
            self.sendVideoActionAnalytics(videoStatus: .pause)
        }
        palyer.pause()
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        guard let palyer = avPlayer else {
            return
        }
        palyer.seek(to: CMTime.zero)
        palyer.play()
    }
    
    @objc func playPauseAction()
    {
        scrollToActualPosition()
        
        if self.playVideoBtn?.isHidden ?? false
        {
            self.pauseVideo()
        }else{
            self.playVideo()
        }
    }
    
    @objc func startVideo(_ sender : UIButton)
    {
        self.playVideo()
    }
}



extension UserDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    fileprivate func setupCollectionView()
    {
        self.collectionView.register(UINib.init(nibName: "InterestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellIdentifier")
        
        let flowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 20, right: 5)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.interestList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cellIdentifier" , for: indexPath) as! InterestCollectionViewCell
        
        var subCategory = interestList[indexPath.row]
        subCategory.thumbUrl = self.categoryImageUrl(subCategory: subCategory).0
        subCategory.selectedThumbUrl = categoryImageUrl(subCategory: subCategory).1
        cell.myProfile = self.myProfile
        cell.subCategory = subCategory
        
        print("subCategory : \(subCategory.thumbUrl)")
        
        if self.isSelected(subCategory: subCategory) {
            cell.selectedInterest = true
        }else{
            cell.selectedInterest = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let string : String = interestList[indexPath.row].name ?? ""
        let label = UILabel(frame: CGRect.zero)
        
        label.font = UIFont.autoScale(weight: .regular, size: CGFloat(14))
        label.text = string
        label.sizeToFit()
        let height = label.frame.height*2
        let iconSize = height*0.7
        let width = label.frame.width  + iconSize + 30
        return CGSize(width: width, height: height)
    }
    
    fileprivate func categoryImageUrl(subCategory : SubCategory) -> (String?,String?)
    {
        if subCategory.thumbUrl == "addMore"
        {
            return ("addMore","addMore")
        }
        let subCategory = self.allInterestList.filter { $0.id == subCategory.id }
        return (subCategory.first?.thumbUrl,subCategory.first?.selectedThumbUrl)
    }
    
    fileprivate func isSelected(subCategory : SubCategory?) -> Bool
    {
        guard let subCategory = subCategory else {
            return false
        }
        return mutualInterestList.contains(subCategory)
    }
}

extension UserDetailViewController {
    
    enum VideoStatus : String{
        case open
        case play
        case pause
        case close
    }
    
    enum ProfileStatus : String {
        case open
        case close
    }
    
    private func openProfileAnalytics(profileStatus : ProfileStatus){
        if let uniqueId = profile?.uniqueId {
            AppAnalytics.log(.profileOpen(uniqueid: uniqueId, action: profileStatus.rawValue))
            TPAnalytics.log(.profileOpen(uniqueid: uniqueId, action: profileStatus.rawValue))
        }
        
    }
    
    private func sendAddDeleteAnalytics(){
        if let uniqueId = profile?.uniqueId {
            if self.favBtn.isSelected {
                AppAnalytics.log(.bookmark(uniqueid: uniqueId, action: "false"))
                TPAnalytics.log(.bookmark(uniqueid: uniqueId, action: "false"))
            }else {
                AppAnalytics.log(.bookmark(uniqueid: uniqueId, action: "true"))
                TPAnalytics.log(.bookmark(uniqueid: uniqueId, action: "true"))
            }
        }
    }
    
    private func userBlockAnalytics(){
        if let uniqueId = profile?.uniqueId {
            if isBlocked{
                AppAnalytics.log(.block(uniqueid: uniqueId, action: "true"))
                TPAnalytics.log(.block(uniqueid: uniqueId, action: "true"))
            }else {
                AppAnalytics.log(.block(uniqueid: uniqueId, action: "false"))
                TPAnalytics.log(.block(uniqueid: uniqueId, action: "false"))
            }
        }
    }
    
    
    private func sendVideoActionAnalytics(videoStatus: VideoStatus){
        let videoId = self.profile?.videoList?.first?.url?.components(separatedBy: "/").last
        if let uniqueId = profile?.uniqueId , let videoId = videoId{
            AppAnalytics.log(.playPauseVideo(uniqueid: uniqueId, videoId: videoId , action: videoStatus.rawValue))
            TPAnalytics.log(.playPauseVideo(uniqueid: uniqueId,  videoId: videoId , action:  videoStatus.rawValue))
        }
    }
    
    private func sendImageActionAnalytics(imageId: String?){
        if let uniqueId = profile?.uniqueId , let imageId = imageId{
            AppAnalytics.log(.imageView(uniqueId: uniqueId, imageId: imageId))
            TPAnalytics.log(.imageView(uniqueId: uniqueId, imageId: imageId))
        }
    }
}


extension UserDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pauseVideo()
        
        if scrollView == self.verticalScrollView
        {
            let contentOffsetY: CGFloat = verticalScrollView.contentOffset.y
            let newHeaderViewHeight: CGFloat = topMarginScrollView.constant - contentOffsetY
            
            if newHeaderViewHeight > headerMaxHeightForScroll {
                topMarginScrollView.constant = headerMaxHeightForScroll - 20
            } else if newHeaderViewHeight <= headerMinHeight {
                topMarginScrollView.constant = headerMinHeight
            } else {
                topMarginScrollView.constant = newHeaderViewHeight
                //verticalScrollView.contentOffset.y = 0 // block scroll view
            }
        }else {
            scrollToActualPosition()
            // Calculate the new page index depending on the content offset.
            var currentPage = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
            if Int(currentPage) < 0 {
                currentPage = 0
            }
            scrollingPageIndex = Int(currentPage)
        }
    }
    
    
    private func verifyScrollObjects (scrollIndex: Int){
        let resourceObj = resourceList[scrollIndex]
        if (resourceObj as AnyObject) is ImageModel {
            let model = resourceObj as! ImageModel
            if let imageId = model.url?.components(separatedBy: "/").last{
                sendImageActionAnalytics(imageId: imageId)
            }
        }else if (resourceObj as AnyObject) is VideoModel {
            sendVideoActionAnalytics(videoStatus: .open)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.verticalScrollView
        {
            checkAndReturnToActualSize()
        }else {
            if pageControl.currentPage != scrollingPageIndex {
                pageControl.currentPage = scrollingPageIndex
                verifyScrollObjects(scrollIndex: pageControl.currentPage)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.verticalScrollView
        {
            checkAndReturnToActualSize()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == self.verticalScrollView
        {
            checkAndReturnToActualSize()
        }
    }
    
    func checkAndReturnToActualSize()
    {
        let y: CGFloat = verticalScrollView.contentOffset.y
        let newHeaderViewHeight: CGFloat = topMarginScrollView.constant - y
        //print("$$$ : newHeaderViewHeight :\(newHeaderViewHeight)  headerMaxHeight : \(headerMaxHeight)")
        if newHeaderViewHeight >= (headerMaxHeight - 20) {
            topMarginScrollView.constant = headerMaxHeight - 20
        }
    }
    
    func scrollToActualPosition()
    {
        topMarginScrollView.constant = headerMaxHeight - 20
    }
}

extension UserDetailViewController: AlertViewDelegate {
    func okButtonAction(tag: Int) {
        if tag == 1 {
            if let uniqeId = profile?.uniqueId {
                DatabaseManager.shared.deleteProfile(uniqueId: uniqeId)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func cancelButtonAction(tag: Int) {
        
    }
    
    
}

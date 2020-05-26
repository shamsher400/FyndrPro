//
//  ProfileDetailViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVKit


class ProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView : DynamicHeightCollectionView!

    @IBOutlet weak var profilePic : UIImageView!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var cityLbl : UILabel!
    
    @IBOutlet weak var bioLbl : UILabel!
    @IBOutlet weak var bioPic : UIImageView!
    @IBOutlet weak var updateBtn : UIButton!
    @IBOutlet weak var manageInterestLbl : UILabel!
    
    @IBOutlet weak var videoPlayerView : AVPlayerView!
    @IBOutlet weak var playVideoBtn : UIButton!
    @IBOutlet weak var noVideoView: UIView!
    @IBOutlet weak var noVideoLbl: UILabel!
    
    fileprivate var avPlayer: AVPlayer?
    fileprivate var avPlayerLayer : AVPlayerLayer?
    
    fileprivate var interestNameList = [String]()
    fileprivate var addMore = ""
    fileprivate var interestList = [SubCategory]()
    fileprivate var allInterestList = [SubCategory]()

    var myProfile : Profile?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("My Profile", comment: "")
        self.view.bringSubviewToFront(self.noVideoView)
        
        self.nameLbl.font = UIFont.autoScale(weight: .regular, size: 23)
        self.cityLbl.font = UIFont.autoScale(weight: .regular, size: 15)
        self.manageInterestLbl.font = UIFont.autoScale(weight: .semibold, size: 17)
        
        self.bioLbl.font = UIFont.autoScale(weight: .regular, size: 15)
        self.updateBtn.titleLabel?.font = UIFont.autoScale(weight: .medium, size: 13)
        
        self.noVideoView.isHidden = true
        setupNavbar()
        setupCollectionView()
        self.allInterestList = Util.getInterestList()?.subCategories ?? [SubCategory]()
        
        bioLbl.text = NSLocalizedString("Bio", comment: "")
        updateBtn.setTitle(NSLocalizedString("Update", comment: ""), for: .normal)
        self.manageInterestLbl.text = NSLocalizedString("M_MANAGE_YOUR_INTERESR", comment: "")
        addMore = NSLocalizedString("M_ADD_MORE", comment: "")

    }

    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .updateProfile))
        TPAnalytics.log(.openScreen(screen: .updateProfile))
        myProfile = Util.getProfile()
        setUIValues()
    }
    
    fileprivate func setUIValues()
    {
        bioLbl.text = NSLocalizedString("Bio", comment: "")
        updateBtn.setTitle("Update", for: .normal)
        cityLbl.text = myProfile?.city?.name
        videoPlayerView.isHidden = true
        profilePic.image = Util.defaultThumImage()
        nameLbl.text = myProfile?.name

        guard let profile = self.myProfile, let uniqueId = profile.uniqueId else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if let urlString = profile.imageList?.first?.url
        {
            profilePic.setKfImage(url: urlString, placeholder: Util.defaultThumImage(), uniqueId: uniqueId)
        }
        self.interestList = profile.interests ?? [SubCategory]()
        self.interestList.append(SubCategory.init(id: "add", name: addMore, thumbUrl: "addMore"))
        
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
     
        guard let urlString = profile.videoList?.first?.url else{
            self.noVideoView.isHidden = false
            print("Video url not found")
            return
        }
        self.noVideoView.isHidden = true
        
        if let thumbUrl = profile.videoList?.first?.thumbUrl
        {
            self.bioPic.setKfImage(url: thumbUrl, placeholder: Util.defaultBioThumImage(), uniqueId: uniqueId)
        }
        
        let fileManager = AppFileManager.init()
        let localFilePath = fileManager.getRecodingFilePath()
        
        if !fileManager.isFileExistAt(path: localFilePath)
        {
            print("video not exist so start downlaod")
            if Reachability.isInternetConnected()
            {
            var urlString = "\(urlString)?deviceId=\(Util.deviceId())&userId=\(uniqueId)&type=download"
            if PUBLIC_IP {
                urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
            }
            RequestManager.shared.downloadRequest(url: urlString,destinationUrl :localFilePath, onCompletion: { (response) in
                DispatchQueue.main.async {
                    self.videoPlayerView.isHidden = false
                    self.initPlayerViewWithLocalUrl(videoUrl: localFilePath)
                }
            }, onFailure: { (error) in
                print("Error : \(String(describing: error?.localizedDescription))")
            }) { (progress) in
               // print("Progress :\(String(describing: progress?.completedUnitCount))")
            }
            }
            
        }else{
            print("video already exist")
            self.videoPlayerView.isHidden = false
            self.initPlayerViewWithLocalUrl(videoUrl: localFilePath)
        }
    }
    
    fileprivate func setupNavbar()
    {
        let backBtn = UIButton.init(type: .custom)
        backBtn.setImage(UIImage(named: "back-ios"), for: .normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 30)
        backBtn.backgroundColor = UIColor.clear
        backBtn.addTarget(self, action: #selector(dismissView), for: UIControl.Event.touchUpInside)
        backBtn.contentHorizontalAlignment = .left
        backBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -8, bottom: 0, right: 0)
        let backBarButton = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    
    @objc func dismissView()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openEditProfile()
    {
        let createProfile = UIStoryboard.loadEditProfileViewController() as! EditProfileViewController
        createProfile.editProfile = true
        createProfile.myProfile = self.myProfile
        self.navigationController?.pushViewController(createProfile, animated: true)
    }
    
    //MARK: - Button Action
    @IBAction func updateButtonAction(_ sender : UIButton)
    {
        openEditProfile()
    }
    
    @IBAction func editButtonAction(_ sender : UIButton)
    {
        openEditProfile()
    }
    
    @IBAction func playVideoButtonAction(_ sender : UIButton)
    {
        /*
        let videoPath = AppFileManager.init().getRecodingFilePath()
        if AppFileManager.init().isFileExistAt(path: videoPath)
        {
            let localFileUrl = URL.init(fileURLWithPath: videoPath)
            let videoPreviewViewController = UIStoryboard.getViewController(identifier: "VideoPreviewViewController") as! VideoPreviewViewController
            videoPreviewViewController.videoURL = localFileUrl
            self.present(videoPreviewViewController, animated: true, completion: nil)
        }
        */
        self.playPauseAction()
    }
    @IBAction func addBioButtonAction(_ sender: UIButton) {
        openEditProfile()
    }
    
    fileprivate func openInterestSelectionView()
    {
        let interestViewController = UIStoryboard.getViewController(identifier: "InterestViewController") as! InterestViewController
        interestViewController.editProfile = true
        interestViewController.myProfile = self.myProfile
        self.navigationController?.pushViewController(interestViewController, animated: true)
    }
}

extension ProfileDetailViewController: AVAudioPlayerDelegate
{
    func initPlayerViewWithLocalUrl(videoUrl : String)
    {
        let item = AVPlayerItem(url: URL(fileURLWithPath: videoUrl))
        self.avPlayer = AVPlayer(playerItem: item)
        self.avPlayer?.actionAtItemEnd = .none

        let playerLayer = videoPlayerView.layer as! AVPlayerLayer
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.player = avPlayer
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
        
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
        
        let tabGesture = UITapGestureRecognizer.init(target: self, action: #selector(playPauseAction))
        self.videoPlayerView.addGestureRecognizer(tabGesture)
        self.videoPlayerView.backgroundColor = UIColor.black
    }
    
    func playVideo(){
        guard let palyer = avPlayer else {
            return
        }
        self.playVideoBtn?.isHidden = true
        palyer.play()
    }
    
    func pauseVideo(){
        guard let palyer = avPlayer else {
            return
        }
        self.playVideoBtn?.isHidden = false
        palyer.pause()
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        
        guard let palyer = avPlayer else {
            return
        }
        palyer.seek(to: CMTime.zero)
        palyer.pause()
        self.playVideoBtn?.isHidden = false
      //  palyer.play()
    }
    
    @objc func playPauseAction()
    {
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


extension ProfileDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    fileprivate func setupCollectionView()
    {
        self.collectionView.register(UINib.init(nibName: "InterestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellIdentifier")
        
        let flowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 20, right: 10)
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
        subCategory.thumbUrl = categoryImageUrl(subCategory: subCategory).0
        subCategory.selectedThumbUrl = categoryImageUrl(subCategory: subCategory).1
        cell.myProfile = self.myProfile
        cell.subCategory = subCategory
        
      
        if subCategory.name == addMore
        {
            cell.selectedInterest = true
           // cell.cardView.backgroundColor = UIColor.appPrimaryColor
           // cell.subCatLabel.textColor = UIColor.white
        }else{
            cell.selectedInterest = false
           // cell.cardView.backgroundColor = UIColor.white
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let subCategory = interestList[indexPath.row]
        if subCategory.name == addMore
        {
            self.openInterestSelectionView()
        }
    }
    
    fileprivate func categoryImageUrl(subCategory : SubCategory) -> (String?,String?)
    {
        let subCategory = self.allInterestList.filter { $0.id == subCategory.id }
        return (subCategory.first?.thumbUrl,subCategory.first?.selectedThumbUrl)
    }
}

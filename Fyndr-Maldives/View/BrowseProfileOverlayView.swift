//
//  BrowseProfileOverlayView.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import Koloda
import AVKit

protocol BrowseProfileOverlayViewDelegate {
    func playView(fileUrl : URL)
}

class BrowseProfileOverlayView : UIView {
    
    var chatButtonPressed : ((Profile?) -> Void)?
    var profileDetailButtonPressed : ((Profile?) -> Void)?
    var profileImageClick : ((Profile?) -> Void)?

    var collectionViewHeight = CGFloat(100)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var lookingFor: UILabel!
    
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    
    var height = CGFloat(0)
    var resourceList = [Any]()
    
    var delegate : BrowseProfileOverlayViewDelegate?
    
    var myProfile : Profile?
    var profile : Profile? {
        didSet
        {            
            guard let profile = profile  else {
                return
            }
            self.name.text = profile.name
            self.city.text = profile.city?.name
            self.callBtn.isHidden = true
            
            if profile.contactNumber != nil && (profile.contactNumber?.count)! > 0
            {
                self.callBtn.isHidden = false
            }
            if let imageModel = profile.imageList?.first
            {
                resourceList.append(imageModel)
            }
            if let videoModel = profile.videoList?.first
            {
                resourceList.append(videoModel)
            }
            setupCollectionView()
        }
    }
    
    deinit {
       // print("deinit BrowseProfileOverlayView")
    }
    
    @IBAction func chatButtonAction(_ sender: Any) {
        print("Chat button profileId : \(String(describing: profile?.uniqueId))")
        
        if let chatButtonPressed = chatButtonPressed
        {
            chatButtonPressed(profile)
        }
    }
    
    @IBAction func callButtonAction(_ sender: Any) {
        _ = CallHandler.initiateCall(profile: profile, chatHistory: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func openProfileDetail()
    {
        if let profileDetailButtonPressed = profileDetailButtonPressed
        {
            profileDetailButtonPressed(profile)
        }
    }
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(openProfileDetail))
        self.contentView.addGestureRecognizer(tapGesture)

        self.name.font = UIFont.autoScale(weight: .medium, size: 23)
        self.city.font = UIFont.autoScale(weight: .regular, size: 15)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}



extension BrowseProfileOverlayView : UIScrollViewDelegate
{
    func stopVideo()
    {
        self.collectionView.subviews.forEach {
            
            if $0.isKind(of: BrowseProfileCollectionViewCell.self)
            {
                ($0 as? BrowseProfileCollectionViewCell)?.pauseVideo()
            }
        }
    }
    
    func updatePage()
    {
        print("updatePage")
    }
    
    fileprivate func setupCollectionView()
    {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        
        self.collectionView.register(UINib.init(nibName: "BrowseProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BrowseProfileCollectionViewCell")
        
        
        var topSafeAreaHeight: CGFloat = 0
        var bottomSafeAreaHeight: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            topSafeAreaHeight = safeFrame.minY
            bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        }
        height = (SCREEN_HEIGHT - topSafeAreaHeight - bottomSafeAreaHeight - collectionViewHeight - 44)*0.95*0.85 - 15
    }
}

extension BrowseProfileOverlayView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resourceList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseProfileCollectionViewCell", for: indexPath) as! BrowseProfileCollectionViewCell
        cell.myProfile = self.myProfile
        cell.delegate = self
        
        if resourceList.count > indexPath.row
        {
            let resource = resourceList[indexPath.row]
            cell.resource = resource
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? BrowseProfileCollectionViewCell {
            cell.pauseVideo()
        }
    }
}

extension BrowseProfileOverlayView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)

        if resourceList.count > indexPath.row
        {
            let resource = resourceList[indexPath.row]
            if (resource as AnyObject) is ImageModel
            {
                if let profileImageClick = self.profileImageClick
                {
                    profileImageClick(profile)
                }
            }
        }
    }
}

extension BrowseProfileOverlayView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor(SCREEN_WIDTH*0.95), height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.frame.height
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
    }
}


extension BrowseProfileOverlayView : BrowseProfileCollectionViewCellDelegate
{
    func playView(fileUrl: URL) {
        guard let delegate = delegate else {
            return
        }
        delegate.playView(fileUrl: fileUrl)
    }
    
}

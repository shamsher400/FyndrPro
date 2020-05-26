//
//  BrowseProfileCollectionViewCell.swift
//  Fyndr
//
//  Created by BlackNGreen on 14/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher

protocol BrowseProfileCollectionViewCellDelegate {
    func playView(fileUrl : URL)
}

class BrowseProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    var delegate : BrowseProfileCollectionViewCellDelegate?
    
    var avPlayer: AVPlayer?
    var avPlayerLayer : AVPlayerLayer?
    var playVideoBtn : UIButton?
    var videoIdStr = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var myProfile : Profile?
    
    var resource : Any? {
        didSet
        {
            guard let resource = resource, let myProfile = myProfile , let uniqueId = myProfile.uniqueId else {
                return
            }
            var imageUrlString : String?
            if (resource as AnyObject) is ImageModel
            {
                // Image
                let imageObj = resource as! ImageModel
                imageUrlString = imageObj.url
                
            }else{
                // Video
                self.backgroundColor = UIColor.black
                let videoObj = resource as! VideoModel
                imageUrlString = videoObj.thumbUrl
                //self.initPlayerInView(containerView: self, videoModel: videoObj)
                
                // Set Video
                if let urlString = videoObj.url
                {
                    let fileManager = AppFileManager.init()
                    
                    if let fileName = urlString.components(separatedBy: "/").last
                    {
                        videoIdStr = fileName
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
                                        self.initPlayerViewWithLocalUrl(containerView: self, videoUrl: localFilePath)
                                    }
                                }
                            }, onFailure: { (error) in
                                print("error : \(String(describing: error?.localizedDescription))")
                            }) { (progress) in
                                //print("progress :\(String(describing: progress?.completedUnitCount))")
                            }
                        }else{
                            self.initPlayerViewWithLocalUrl(containerView: self, videoUrl: localFilePath)
                        }
                    }
                }
            }
            
            if let urlString = imageUrlString
            {
                profilePic.setKfImage(url: urlString, placeholder: Util.defaultBioThumImage(), uniqueId: uniqueId)
            }else{
                profilePic.image = Util.defaultBioThumImage()
            }
        }
    }
    
    /*
     @IBAction func playVideoButtonAction(_ sender : UIButton)
     {
     return
     
     guard let resource = resource else {
     return
     }
     
     if (resource as AnyObject) is VideoModel
     {
     let videoObj = resource as! VideoModel
     
     if let urlString = videoObj.url
     {
     let fileManager = AppFileManager.init()
     
     if let fileName = urlString.components(separatedBy: "/").last
     {
     let localFilePath = fileManager.filePath(fileNameWithExtension: "\(fileName).mp4")
     let localFileUrl = URL.init(fileURLWithPath: localFilePath)
     
     guard let delegate = delegate else {
     return
     }
     delegate.playView(fileUrl: localFileUrl)
     }
     }
     }
     }
     */
    
    deinit {
        print("deinit BrowseProfileCollectionViewCell")
        guard let palyer = avPlayer else {
            return
        }
        palyer.pause()
        avPlayer = nil
    }
    
}

extension BrowseProfileCollectionViewCell
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
        self.layer.addSublayer(self.avPlayerLayer!)
        
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
    
    
    /*
     func initPlayerInView(containerView : UIView, videoModel : VideoModel)
     {
     guard let urlString = videoModel.url, let uniqueId = myProfile?.uniqueId else {
     return
     }
     
     var videoUrl = "\(urlString)?deviceId=\(Util.deviceId())&userId=\(uniqueId)"
     if PUBLIC_IP {
     videoUrl = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
     }
     let videoURL = URL(string: "http://172.20.12.111:8087/profileManager/postlogin/avi/a3ee12/v156047860013979?deviceId=7d767c79f564957&userId=a1bf3f")
     
     let item = AVPlayerItem(url: videoURL!)
     
     self.avPlayer = AVPlayer(playerItem: item)
     self.avPlayer?.actionAtItemEnd = .none
     
     self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
     self.avPlayerLayer?.videoGravity = .resizeAspectFill
     self.avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
     NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
     self.layer.addSublayer(self.avPlayerLayer!)
     
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
     
     */
    
    func playVideo(){
        guard let palyer = avPlayer else {
            return
        }
        videoPlayAndPauseAnalytics(isPlay: true)

        self.playVideoBtn?.isHidden = true
        palyer.play()
    }
    
    func pauseVideo(){
        guard let palyer = avPlayer else {
            return
        }
        
        if avPlayer?.rate != 0 {
            videoPlayAndPauseAnalytics(isPlay: false)
        }
        self.playVideoBtn?.isHidden = false
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
    
    
    private func videoPlayAndPauseAnalytics(isPlay: Bool){
        if let uniqueId = myProfile?.uniqueId {
            if isPlay{
                AppAnalytics.log(.playPauseVideo(uniqueid: uniqueId, videoId: videoIdStr, action: "play"))
                TPAnalytics.log(.playPauseVideo(uniqueid: uniqueId,  videoId: videoIdStr, action: "play"))
            }else {
                AppAnalytics.log(.playPauseVideo(uniqueid: uniqueId, videoId: videoIdStr, action: "pause"))
                TPAnalytics.log(.playPauseVideo(uniqueid: uniqueId, videoId: videoIdStr, action: "pause"))
            }
        }
    }
}



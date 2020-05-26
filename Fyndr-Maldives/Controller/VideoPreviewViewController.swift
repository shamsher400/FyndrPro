//
//  VideoPreviewViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoPreviewViewController: UIViewController {
    
    @IBOutlet weak var uploadButton : UIButton!
    @IBOutlet weak var cancelButton : UIButton!
    @IBOutlet weak var playPauseButton : UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    var videoURL: URL!
    var viewOnly: Bool = true
    var profile: Profile?
   // var player: AVPlayer?
   // var playerController : AVPlayerViewController?
    
    var avPlayer: AVPlayer?
    var avPlayerLayer : AVPlayerLayer?

    //var safeView : UIView!
    
    //    init(videoURL: URL, viewOnly : Bool) {
    //        self.videoURL = videoURL
    //        self.viewOnly = viewOnly
    //        super.init(nibName: nil, bundle: nil)
    //    }
    
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewOnly
        {
//            self.uploadButton.isHidden = true
            self.uploadButton.setImage(UIImage(named: "delbio_icon"), for: .normal)
        }
        self.playPauseButton.isHidden = true
        
        
        
        let item = AVPlayerItem(url: videoURL!)
        self.avPlayer = AVPlayer(playerItem: item)
        self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        self.avPlayerLayer?.videoGravity = .resizeAspect
        self.avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
        //self.view.layer.addSublayer(self.avPlayerLayer!)
        
        self.view.layer.insertSublayer(self.avPlayerLayer!, at: 0)
        
        
        // Allow background audio to continue to play
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        let tabGuesture = UITapGestureRecognizer.init(target: self, action: #selector(playPauseAction))
        self.view.addGestureRecognizer(tabGuesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .playView))
        TPAnalytics.log(.openScreen(screen: .playView))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.avPlayer?.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        print("deinit : VideoPreviewViewController")
    }
    
    @objc func playPauseAction()
    {
        if self.playPauseButton.isHidden
        {
            self.playPauseButton.isHidden = false
            self.avPlayer?.pause()
        }else{
            self.playPauseButton.isHidden = true
            self.avPlayer?.play()
        }
    }
    
    @IBAction func playPauseButtonAction(_ sender: Any) {
        playPauseAction()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        if !viewOnly {
        let alertView = AlertView()
        alertView.delegate = self
        alertView.showAlert(vc: self, title: "", message: NSLocalizedString("M_DISCART_VIDEO_MESSAGE", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), tag: 1)
        }else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func uploadButtonAction(_ sender: Any) {
        if viewOnly {
            if let myProfile = profile{
                let videoUrl = myProfile.videoList?.first?.url
                let urlArray = videoUrl?.components(separatedBy: "/")
                if let videoId = urlArray?.last {
                    deleteVideoFromServer(uid: myProfile.uniqueId ?? "", vedioId: videoId)
                }
            }
        }else {
            uploadVideoOnServer()
            sendUploadActionToAnalytics(videoStatus: .upload)
        }
        
    }
    

    private func deleteVideoFromServer(uid: String, vedioId: String){
        
        self.avPlayer?.pause()
        if Reachability.isInternetConnected() {
            Util.showLoader()
            RequestManager.shared.deleteVideoRequest(uid: uid, vedioId: vedioId, onCompletion: { (responseJson) in
                let response =  Response.init(json: responseJson)
                if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                {
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        self.profile?.videoList = nil
                        self.profile?.videoListString = nil
                        
                        Util.saveProfile(myProfile: self.profile)
                        
                        self.sendUploadActionToAnalytics(videoStatus: .delete)
                        AppFileManager.init().deleteFileFromPath(filePath: self.videoURL.path)
                        self.dismiss(animated: true, completion: nil)
                    }
                }else {
                    DispatchQueue.main.async {
                        Util.hideLoader()

                        print("deleteVideoFromServer()  : \(String(describing: response.reason))")
                        AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }) { (error) in
                print("error : \(String(describing: error?.localizedDescription))")
                Util.hideLoader()
                AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
            }
            
        }else {
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
        
    }
    
    
    @objc func uploadVideoOnServer()
    {
        self.avPlayer?.pause()
        
        if Reachability.isInternetConnected()
        {
            do{
                let data = try Data.init(contentsOf: self.videoURL)
                let size = data.count
                let mb = Double(size) / (1024.0 * 1000)
                print("Video size in byte : \(size) in MB : \(mb)")
                
                let fileName = "story.mp4"
                Util.showLoader()
                
                RequestManager.shared.createResourceRequest(type: ResourceType.video, name: fileName, size: Int(size), onCompletion: { (responseJson) in
                    
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        if let urlString = responseJson["url"].string
                        {
                            var url = urlString
                            if PUBLIC_IP {
                                url = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
                            }
                            
                            RequestManager.shared.uploadResourceRequest(data: data, fileName: fileName, resourceUrl: url, onCompletion: { (responseJson) in
                                
                                DispatchQueue.main.async {
                                    Util.hideLoader()
                                    
                                    let response =  UploadVideoResponse.init(json: responseJson)
                                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                                    {
                                     
                                        self.sendUploadActionToAnalytics(videoStatus: .success)
                                        print("Video upload success")
                                        AppFileManager.init().deleteMyRecodingFile()
                                        AppFileManager.init().copyAndDeleteRecordingFile(from: self.videoURL)
                                        
                                        var myProfile = Util.getProfile()
                                        myProfile?.isVideo = true
                                        let videoModel = VideoModel.init(url: response.url, thumbUrl: response.thumbUrl, name: fileName, size: size)
                                        myProfile?.videoList = [videoModel]
                                        Util.saveProfile(myProfile: myProfile)
                                        
                                        self.dismissViewController()
                                        
                                    }else{
                                        print("Failed to upload video : \(String(describing: response.reason))")
                                        AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                                        self.sendUploadActionToAnalytics(videoStatus: .failed)
                                    }
                                }
                                
                            }, onFailure: { (error) in
                                Util.hideLoader()
                                print("Error : \(String(describing: error?.localizedDescription))")
                                self.sendUploadActionToAnalytics(videoStatus: .failed)
                            }, onProgress: { (progress) in
                                print("Upload Progress in view : \(String(describing: progress?.fractionCompleted))")
                            })
                        }else{
                            Util.hideLoader()
                            self.sendUploadActionToAnalytics(videoStatus: .failed)
                            
                            AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                            print("Invalid URL in response from server in create resource for video upload")
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            Util.hideLoader()
                            if let reason = response.reason {
                                AlertView().showAlert(vc: self, message: reason)
                            }else
                            {
                                AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                            }
                            self.sendUploadActionToAnalytics(videoStatus: .failed)
                        }
                    }
                    
                }) { (error) in
                    print("error : \(String(describing: error?.localizedDescription))")
                    Util.hideLoader()
                    AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    self.sendUploadActionToAnalytics(videoStatus: .failed)
                }
            }catch {
                print("Failed to convert video in data")
            }
        }
        else {
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        
        self.playPauseButton.isHidden = false
        self.avPlayer?.seek(to: CMTime.zero)
       // self.avPlayer?.play()
    }
    
    
    func dismissViewController()
    {
        self.presentingViewController?
            .presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

extension VideoPreviewViewController {
    
    enum VideoStatus : String{
        case upload
        case failed
        case success
        case delete
    }
    
    public func sendUploadActionToAnalytics(videoStatus: VideoStatus){
        AppAnalytics.log(.recordVideo(action: videoStatus.rawValue))
        TPAnalytics.log(.recordVideo(action: videoStatus.rawValue))
    }
}

extension VideoPreviewViewController: AlertViewDelegate {
    func okButtonAction(tag: Int) {
        if tag == 1 {
            AppFileManager.init().deleteFileFrom(url: self.videoURL)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func cancelButtonAction(tag: Int) {
        
    }
    
    
}

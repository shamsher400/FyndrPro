//
//  DownloadManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 05/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import Kingfisher


enum FileDownloadStatus {
    case none
    case downloaded
    case inProgress
}

protocol DownloadManagerDelegate {
    func downloadStatusChange(_ success: Bool, _ error :  Error?,_ filePath : String)
}

class DownloadManager {
    
    typealias fileDownloadStatus = (_ status: FileDownloadStatus,_ filePath : String) -> Void
    typealias downloadStatusChange = (_ success: Bool, _ error :  Error?) -> Void
    
    var delegate : DownloadManagerDelegate?
    var pendingRequestList = [String]()
    
    static let shared = DownloadManager()
    private init() { }
    
    
    func downloadVideoForProfiles(profiles: [Profile])
    {
        //TODO Remove
        return
        
        if Reachability.isInternetConnected() {
            
            guard let uniqueId =  UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID) else{
                return
            }
            print("DM : download video count : \(profiles.count)")
            
            for profile in profiles
            {
                if let videoUrl = profile.videoList?.first?.url
                {
                    if let localFilePath = getLocalFilePath(urlString: videoUrl) {
                        print("DM : check and start downlaod video file name : \(String(describing: localFilePath.components(separatedBy: "/").last))")
                        
                        let fileManager = AppFileManager.init()
                        if !fileManager.isFileExistAt(path: localFilePath)
                        {
                            var urlString = "\(videoUrl)?deviceId=\(Util.deviceId())&userId=\(uniqueId)&type=download"
                            if PUBLIC_IP {
                                urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
                            }
                            if !pendingRequestList.contains(urlString)
                            {
                                self.startDownlaod(urlString: urlString, localFilePath : localFilePath)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    fileprivate func getLocalFilePath(urlString : String) -> String?
    {
        let fileManager = AppFileManager.init()
        if let fileName = urlString.components(separatedBy: "/").last
        {
            return fileManager.filePath(fileNameWithExtension: "\(fileName).mp4")
        }
        return nil
    }
    
    
    func getVideoFileStatus(urlString : String, onCompletion fileDownloadStatus: @escaping fileDownloadStatus)
    {
        guard let uniqueId =  UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID) else{
            fileDownloadStatus(.none,"")
            return
        }
        
        let fileManager = AppFileManager.init()
        if let fileName = urlString.components(separatedBy: "/").last
        {
            print("DM : get video status for \(fileName)")
            
            let localFilePath = fileManager.filePath(fileNameWithExtension: "\(fileName).mp4")
            
            if fileManager.isFileExistAt(path: localFilePath)
            {
                print("DM : video exist)")
                fileDownloadStatus(.downloaded,localFilePath)
            }else{
                var urlString = "\(urlString)?deviceId=\(Util.deviceId())&userId=\(uniqueId)&type=download"
                if PUBLIC_IP {
                    urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
                }
                if pendingRequestList.contains(urlString)
                {
                    print("DM : video inprogress)")
                    fileDownloadStatus(.inProgress,localFilePath)
                }else{
                    print("DM : video start downlaod)")
                    fileDownloadStatus(.inProgress,localFilePath)
                    self.startDownlaod(urlString: urlString, localFilePath : localFilePath)
                }
            }
        }
    }
    
    
    func startDownlaod(urlString : String, localFilePath : String)
    {
        if Reachability.isInternetConnected() {
            print("DM : start downlaod \(String(describing: localFilePath.components(separatedBy: "/").last))")
            self.pendingRequestList.append(urlString)
            RequestManager.shared.downloadRequest(url: urlString, destinationUrl :localFilePath, onCompletion: { (response) in
                self.pendingRequestList.removeAll(where: { $0 == localFilePath})
                
                let fileManager = AppFileManager.init()
                if fileManager.isFileExistAt(path: localFilePath)
                {
                    print("DM : download success \(String(describing: localFilePath.components(separatedBy: "/").last))")
                    self.delegate?.downloadStatusChange(true, nil, localFilePath)
                }else{
                    print("DM : download failed \(String(describing: localFilePath.components(separatedBy: "/").last))")
                    self.delegate?.downloadStatusChange(false, AppError.fileNotFound, localFilePath)
                }
            }, onFailure: { (error) in
                print("DM : download error \(String(describing: localFilePath.components(separatedBy: "/").last))")
                self.pendingRequestList.removeAll(where: { $0 == localFilePath})
                self.delegate?.downloadStatusChange(false, AppError.failedTodownlaodVideo, localFilePath)
            }) { (progress) in
            }
        }else{
            self.delegate?.downloadStatusChange(false, AppError.noInternet, localFilePath)
        }
    }
    
    func discardVideo(profile : Profile)
    {
        guard let uniqueId =  UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID) else{
            return
        }
        if let videoUrl = profile.videoList?.first?.url
        {
            if let localFilePath = getLocalFilePath(urlString: videoUrl) {
                
                var urlString = "\(videoUrl)?deviceId=\(Util.deviceId())&userId=\(uniqueId)&type=download"
                if PUBLIC_IP {
                    urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
                }
                RequestManager.shared.cancelRequestWithUrl(url: urlString)

                print("DM : discard video file name : \(String(describing: localFilePath.components(separatedBy: "/").last))")
                
                let fileManager = AppFileManager.init()
                if fileManager.isFileExistAt(path: localFilePath)
                {
                    print("DM : delete local file name : \(String(describing: localFilePath.components(separatedBy: "/").last))")
                    fileManager.deleteFileFromPath(filePath: localFilePath)
                }
                self.pendingRequestList.removeAll(where: { $0 == urlString})
            }
        }
    }
    
    func loadImageFromWithoutUi(profiles: [Profile],onCompletion downloadStatusChange: @escaping downloadStatusChange) {
        let loadImageCount = profiles.count > 3 ? 3 : profiles.count
        var count = 0
        let myProfile = Util.getProfile()
        
        for index in 0..<loadImageCount
        {
            let profile = profiles[index]
            let downloader = KingfisherManager.shared.downloader
            downloader.trustedHosts = Set([DOMAIN_NAME])
            let urlStr = "\(profile.imageList?.first?.url ?? "")?deviceId=\(Util.deviceId())&userId=\(myProfile?.uniqueId ?? "")"
            let imageView = UIImageView.init()
            if let url = URL.init(string: urlStr){
                print("requestUrl \(url)")
                imageView.kf.setImage(with: url, options: [.requestModifier(Request.resourceHeader()), .downloader(downloader)]) { result in
                    switch result {
                    case .success(_):
                        print("success")
                        count = count + 1
                        if count == loadImageCount{
                            downloadStatusChange(true, nil)
                        }
                        break
                    case .failure(_):
                        print("fail")
                        count = count + 1
                        if count == loadImageCount{
                            downloadStatusChange(true, nil)
                        }
                        break
                    }
                }
            }else{
                count = count + 1
                if count == loadImageCount{
                    downloadStatusChange(true, nil)
                }
            }
        }
    }
}

extension DownloadManager : AuthenticationChallengeResponsable
{
    
}

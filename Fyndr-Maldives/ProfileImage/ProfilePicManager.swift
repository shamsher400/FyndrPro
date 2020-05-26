//
//  ProfilePicManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 18/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

enum ImageSource {
    case camera
    case gallery
    case cancel
}

class ProfilePicManager {
    
    var currentVC : UIViewController!
    var imageSource : ImageSource!
    let pickerController = UIImagePickerController()
    
    private init(){}
    
    
    init(viewController : UIViewController) {
        self.currentVC = viewController
    }
    
    func openImagePicker(imageSource : ImageSource)  {
        sendImageSelectionEvent(source: String(describing: imageSource) )
        switch imageSource {
        case .camera:
            openCamera()
        case .gallery:
            openGallery()
        case .cancel:
            print("ProfilePicManager-: Cancel image picker")

        }
    }
    
    private func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                self.openCameraPicker()
                
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.openCameraPicker()
                    }
                }
                //denied - The user has previously denied access.
            //restricted - The user can't grant access due to restrictions.
            case .denied, .restricted:
                self.showPermissionAlert(imageSource: .camera)
            default:
                break
            }
        }else{
            print("camera is not available")
            sendImageSelectionEvent(source: "camera non")
        }
    }
    
    private func openCameraPicker() {
        
        pickerController.allowsEditing = false
        pickerController.delegate = (currentVC as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        pickerController.sourceType = .camera
       // currentVC.present(pickerController, animated: true, completion: nil)
        currentVC.modalPresentationStyle = .fullScreen
        currentVC.present(pickerController, animated: true) {
           // self.pickerController.navigationBar.topItem?.rightBarButtonItem?.tintColor = .white
        }
    }
    
    private func openGallery() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            let status = PHPhotoLibrary.authorizationStatus()
            switch status{
            case .authorized:
                openPhotoLibrary()
            case .denied, .restricted:
                self.showPermissionAlert(imageSource: .gallery)
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized{
                        // photo library access given
                        self.openPhotoLibrary()
                    }
                })
            default:
                break
            }
        }else{
            sendImageSelectionEvent(source: "gallery non")
            print("photo library is not available")
        }
    }
    
    private func openPhotoLibrary() {
        
        pickerController.allowsEditing = false
        pickerController.delegate = (currentVC as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        pickerController.sourceType = .photoLibrary
       // currentVC?.present(pickerController, animated: true, completion: nil)
        currentVC.modalPresentationStyle = .fullScreen
        currentVC?.present(pickerController, animated: true) {
        //    self.pickerController.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.red
        //    self.pickerController.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
            
            
    
            
        }

    }
    
    
    private func showPermissionAlert(imageSource : ImageSource)
    {
        var alertMessage = NSLocalizedString("M_WOULD_LIKE_TO_ACCESS_THE_CAMERA", comment: "")
        if imageSource == .gallery{
            alertMessage = NSLocalizedString("M_WOULD_LIKE_TO_ACCESS_THE_PHOTO", comment: "")
        }
        
        let alertView = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
        
        let settings = UIAlertAction(title: NSLocalizedString("M_SETTING", comment: ""), style: .default){ (action) in
            self.openSettingPage()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("M_CANCEL", comment: ""), style: .default){ (action) in}
        alertView.addAction(settings)
        alertView.addAction(cancel)
        currentVC.modalPresentationStyle = .fullScreen
        currentVC?.present(alertView, animated: true, completion: nil)
    }
    
    private func openSettingPage()
    {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],completionHandler: {(success) in})
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

extension ProfilePicManager{
    private func sendImageSelectionEvent(source: String){
        AppAnalytics.log(.image(action: source))
        TPAnalytics.log(.image(action: source))
    }
    
    private func sendSourceNotFound (source: String, message: String
    ){
        
    }
}

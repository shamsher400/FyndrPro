//
//  ProfilePicEditViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 18/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CropViewController
import Kingfisher

class ProfilePicEditViewController: UIViewController{
    
    @IBOutlet weak var profilePic : UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let rightBarButton = UIBarButtonItem(title: NSLocalizedString("edit", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(editProfilePicButtonAction))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func editProfilePicButtonAction() {
        let url = URL(string: "http://app.magiccall.co/appimages/videoAmbiences/traffic_20_sep_icon.png")
        let processor = DownsamplingImageProcessor(size: self.profilePic.frame.size)
            >> RoundCornerImageProcessor(cornerRadius: 20)
        self.profilePic.kf.indicatorType = .activity
        self.profilePic.kf.setImage(
            with: url,
            placeholder: UIImage(named: "test"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
}

extension ProfilePicEditViewController : UIActionSheetDelegate
{
    private func chooseOption()
    {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deletePhoto = UIAlertAction(title: "Delete Photo", style: .destructive){ (action) in
            
        }
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default){ (action) in
            ProfilePicManager.init(viewController: self).openImagePicker(imageSource: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default){ (action) in
            ProfilePicManager.init(viewController: self).openImagePicker(imageSource: .gallery)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(deletePhoto)
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(choosePhoto)
        optionMenu.addAction(cancel)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}


extension ProfilePicEditViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("pickedImage size : \(pickedImage.sizeInKB())")
            self.openCropViewController(image: pickedImage, picker: picker, croppingStyle : .default)
        }else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}


extension ProfilePicEditViewController : CropViewControllerDelegate
{
    
    private func openCropViewController(image : UIImage, picker : UIImagePickerController , croppingStyle : CropViewCroppingStyle)
    {
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
        // Uncomment this if you wish to provide extra instructions via a title label
        //cropController.title = "Crop Image"
        
        // -- Uncomment these if you want to test out restoring to a previous crop setting --
        //cropController.angle = 90 // The initial angle in which the image will be rotated
        //cropController.imageCropFrame = CGRect(x: 0, y: 0, width: 2848, height: 4288) //The initial frame that the crop controller will have visible.
        
        // -- Uncomment the following lines of code to test out the aspect ratio features --
        //cropController.aspectRatioPreset = .presetSquare; //Set the initial aspect ratio as a square
        //cropController.aspectRatioLockEnabled = true // The crop box is locked to the aspect ratio and can't be resized away from it
        //cropController.resetAspectRatioEnabled = false // When tapping 'reset', the aspect ratio will NOT be reset back to default
        //cropController.aspectRatioPickerButtonHidden = true
        
        // -- Uncomment this line of code to place the toolbar at the top of the view controller --
        //cropController.toolbarPosition = .top
        
        //cropController.rotateButtonsHidden = true
        //cropController.rotateClockwiseButtonHidden = true
        
        //cropController.doneButtonTitle = "Title"
        //cropController.cancelButtonTitle = "Title"
        
       // self.image = image
        
        //If profile picture, push onto the same navigation stack
        if croppingStyle == .circular {
            if picker.sourceType == .camera {
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
            } else {
                picker.pushViewController(cropController, animated: true)
            }
        }
        else { //otherwise dismiss, and then present from the main controller
            picker.dismiss(animated: true, completion: {
                self.present(cropController, animated: true, completion: nil)
                //self.navigationController!.pushViewController(cropController, animated: true)
            })
        }
    }
    
    //MARK:- CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
       // self.updateImageViewWithImage(image, fromCropViewController: cropViewController)
        cropViewController.dismiss(animated: true, completion: nil)
        self.profilePic.image = image
        print("Image size : \(image.sizeInKB())")
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.profilePic.image = image
    }
}

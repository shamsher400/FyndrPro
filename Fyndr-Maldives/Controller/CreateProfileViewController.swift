//
//  CreateBasicViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 06/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Photos
import CropViewController
import SwiftyJSON

enum Gender : String {
    case male = "M"
    case female = "F"
}

class CreateProfileViewController: UIViewController {
    
    @IBOutlet weak var nextButton : UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileImgBgView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    
    @IBOutlet weak var maleOptionView: CardView!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var maleIconImg: UIImageView!
    
    @IBOutlet weak var femaleOptionView: CardView!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var femaleIconImg: UIImageView!
    
    @IBOutlet weak var cityNameView: CardView!
    @IBOutlet weak var cityNameTxt: UITextField!
    
    @IBOutlet weak var dobView: CardView!
    @IBOutlet weak var dobTxt: UITextField!
    
    @IBOutlet weak var recordVideoView: CardView!
    @IBOutlet weak var videoPreviewImg: UIImageView!
    @IBOutlet weak var playVideoBtn : UIButton!
    @IBOutlet weak var playVideoView : CardView!
    @IBOutlet weak var textViewAbout: UITextView!
    @IBOutlet weak var textViewContainer: CardView!
    @IBOutlet weak var ageNote: UILabel!
    
    let aboutPlaceHolderText = NSLocalizedString("M_ABOUT", comment: "")

    let datePicker = UIDatePicker()
    var myProfile : Profile?
    var editProfile = false
    var myTempProfile : Profile?
    
    var gender : Gender? {
        
        didSet
        {
            switch gender {
            case .male?:
                
                self.maleOptionView.borderColor = UIColor.appPrimaryColor
                self.maleOptionView.layer.borderColor = UIColor.appPrimaryColor.cgColor
                self.maleLabel.textColor = UIColor.appPrimaryColor
                maleIconImg.image = UIImage.init(named: "male-icon-sel")
                
                self.femaleOptionView.borderColor = UIColor.lightGray
                self.femaleOptionView.layer.borderColor = UIColor.lightGray.cgColor
                self.femaleLabel.textColor = UIColor.darkGray
                femaleIconImg.image = UIImage.init(named: "female-icon")
                
            case .female?:
                
                self.maleOptionView.layer.borderColor = UIColor.lightGray.cgColor
                self.maleOptionView.borderColor = UIColor.lightGray
                self.maleLabel.textColor = UIColor.darkGray
                maleIconImg.image = UIImage.init(named: "male-icon")
                
                
                self.femaleOptionView.layer.borderColor = UIColor.appPrimaryColor.cgColor
                self.femaleOptionView.borderColor = UIColor.appPrimaryColor
                self.femaleLabel.textColor = UIColor.appPrimaryColor
                femaleIconImg.image = UIImage.init(named: "female-icon-sel")
            case .none: break
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //navigationController?.navigationBar.setGradientBackground(colors: defaultGradientColors)
        
        self.title = NSLocalizedString("Create Profile", comment: "")
        
        self.nameTxt.font = UIFont.autoScale()
        self.femaleLabel.font = UIFont.autoScale()
        self.maleLabel.font = UIFont.autoScale()
        self.cityNameTxt.font = UIFont.autoScale()
        self.dobTxt.font = UIFont.autoScale()
        self.ageNote.font = UIFont.autoScale(weight: FontWeight.regular, size: 11)
        self.ageNote.text = NSLocalizedString("M_AGE_NOTE", comment: "")
        self.dobTxt.placeholder = NSLocalizedString("M_DATE_OF_BIRTH", comment: "")
        self.nameTxt.placeholder = NSLocalizedString("M_NAME", comment: "")


        self.nextButton.titleLabel?.font = UIFont.autoScale(weight: .semibold, size: 17)
        
        if editProfile
        {
            self.nextButton.setTitle(NSLocalizedString("Update", comment: ""), for: .normal)
        }else{
            self.nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        }
        addGestures()
        showDatePicker()
        
        myTempProfile = Util.getProfile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .createProfile))
        TPAnalytics.log(.openScreen(screen: .createProfile))
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.isNavigationBarHidden = false
        myProfile = Util.getProfile()
        self.fillLastSaveData()
    }
    
    override func viewWillLayoutSubviews() {
        nextButton.setGradient(colors: defaultGradientColors)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        if let userInfo = notification.userInfo
        {
            if var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            {
                keyboardFrame = self.view.convert(keyboardFrame, from: nil)
                
                var contentInset:UIEdgeInsets = self.scrollView.contentInset
                contentInset.bottom = keyboardFrame.size.height
                scrollView.contentInset = contentInset
            }
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    
    fileprivate func setTextViewPlaceholder()
    {
        textViewAbout.text = aboutPlaceHolderText
        textViewAbout.textColor = UIColor.lightGray
        textViewAbout.backgroundColor = UIColor.white
        textViewAbout.font = UIFont.autoScale(weight: FontWeight.regular, size: 15)
    }
    
    fileprivate func fillLastSaveData()
    {
        self.playVideoBtn.isHidden = true
        
        if let gender = myTempProfile?.gender {
            self.gender = Gender(rawValue: gender)
        }
        
        self.nameTxt.text = myTempProfile?.name
        self.cityNameTxt.text = myTempProfile?.city?.name
//        self.dobTxt.text = self.myTempProfile?.dob
        
        localisedDisplayDOB(dob: self.myTempProfile?.dob)
        
        if let about = self.myTempProfile?.about 
        {
            self.textViewAbout.text = about
        }else{
            self.setTextViewPlaceholder()
        }
        
        if let uniqueId = myProfile?.uniqueId
        {
            if let urlString = myProfile?.imageList?.first?.url
            {
                profileImg.setKfImage(url: urlString, placeholder: Util.defaultThumImage(), uniqueId: uniqueId)
            }
            
            guard let urlString = myProfile?.videoList?.first?.url, let thumbUrl = myProfile?.videoList?.first?.thumbUrl else{
                self.videoPreviewImg.image = UIImage(named: "")
                return
            }
            
            if myProfile?.videoList?.first?.url != nil
            {
                self.videoPreviewImg.setKfImage(url: thumbUrl, placeholder: Util.defaultBioThumImage(), uniqueId: uniqueId)
                let fileManager = AppFileManager.init()
                let localFilePath = fileManager.getRecodingFilePath()
                if !fileManager.isFileExistAt(path: localFilePath)
                {
                    if Reachability.isInternetConnected() {
                        var urlString = "\(urlString)?deviceId=\(Util.deviceId())&userId=\(uniqueId)&type=download"
                        if PUBLIC_IP {
                            urlString = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
                        }
                        RequestManager.shared.downloadRequest(url: urlString,destinationUrl :localFilePath, onCompletion: { (response) in
                            DispatchQueue.main.async {
                                self.playVideoBtn.isHidden = false
                            }
                        }, onFailure: { (error) in
                            
                        }) { (progress) in
                        }
                    }
                    
                }else{
                    self.playVideoBtn.isHidden = false
                }
            }
        }
    }
    
    
    fileprivate func addGestures()
    {
        let tabGestureMale = UITapGestureRecognizer.init(target: self, action: #selector(maleOptionSelected))
        self.maleOptionView.addGestureRecognizer(tabGestureMale)
        
        let tabGestureFemale = UITapGestureRecognizer.init(target: self, action: #selector(femaleOptionSelected))
        self.femaleOptionView.addGestureRecognizer(tabGestureFemale)
        
        let tabGestureCityName = UITapGestureRecognizer.init(target: self, action: #selector(selectCity))
        self.cityNameView.addGestureRecognizer(tabGestureCityName)
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyPad))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        let tabGesturePlayVideo = UITapGestureRecognizer.init(target: self, action: #selector(playVideoButtonAction))
        self.playVideoView.addGestureRecognizer(tabGesturePlayVideo)
        
        let tabGestureEditPic = UITapGestureRecognizer.init(target: self, action: #selector(chooseImageSource))
        self.profileImgBgView.addGestureRecognizer(tabGestureEditPic)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func hideKeyPad() {
        self.view.endEditing(true)
    }
    
    @objc func maleOptionSelected()
    {
        self.gender = .male
        myTempProfile?.gender = Gender.male.rawValue
    }
    
    @objc func femaleOptionSelected()
    {
        self.gender = .female
        myTempProfile?.gender = Gender.female.rawValue
    }
    
    @objc func selectCity()
    {
        hideKeyPad()
        guard let citySearchVC = UIStoryboard.getViewController(identifier: "CitySearchViewController") as? CitySearchViewController
            else {
                return
        }
        citySearchVC.selectedCity = self.myTempProfile?.city
        citySearchVC.myProfile = myProfile
        citySearchVC.citySelectionComplate = {
            (city,profile) in
            self.myTempProfile?.city = city
        }
        self.navigationController?.pushViewController(citySearchVC, animated: true)
    }
    
    // MARK: - Button Action
    @IBAction func recordVideoButtonAction(_ sender: Any) {
        
        guard let videoCaptureVC = UIStoryboard.getViewController(identifier: "VideoCaptureViewController") as? VideoCaptureViewController else {
            return
        }
        videoCaptureVC.modalPresentationStyle = .fullScreen
        videoCaptureVC.modalPresentationStyle = .fullScreen
        self.present(videoCaptureVC, animated: true, completion: nil)
    }
    
    @IBAction func selectProfileButtonAction(_ sender: Any) {
        chooseImageSource()
    }
    
    @IBAction func playVideoButtonAction(_ sender : UIButton)
    {
        let videoPath = AppFileManager.init().getRecodingFilePath()
        if AppFileManager.init().isFileExistAt(path: videoPath)
        {
            let localFileUrl = URL.init(fileURLWithPath: videoPath)
            
            guard let videoPreviewViewController = UIStoryboard.getViewController(identifier: "VideoPreviewViewController") as?
                VideoPreviewViewController else {
                return
            }
            videoPreviewViewController.videoURL = localFileUrl
            videoPreviewViewController.profile = myProfile
            videoPreviewViewController.modalPresentationStyle = .fullScreen
            self.present(videoPreviewViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        print("Gender : \(String(describing: self.gender))")
        print("City : \(String(describing: self.cityNameTxt.text))")
        
        hideKeyPad()
        validateFields()
    }
    
    fileprivate func validateFields()
    {
        var errorMessage : String?
        
        if myProfile?.imageList?.first?.url != nil {
            
            if Util.isStringNotEmpty(string: myTempProfile?.name)
            {
                if myTempProfile?.gender != nil
                {
                    if myTempProfile?.city?.id != nil
                    {
                        if Util.isStringNotEmpty(string: myTempProfile?.dob)
                        {
                            self.updateProfile()
                        }else {
                            errorMessage = NSLocalizedString("M_INVALID_DOB", comment: "")
                        }
                    }else{
                        errorMessage = NSLocalizedString("M_INVALID_CITY", comment: "")
                    }
                }else{
                    errorMessage = NSLocalizedString("M_SELECT_GENDER", comment: "")
                }
            }else{
                errorMessage = NSLocalizedString("M_INVALID_NAME", comment: "")
            }
        }else{
            errorMessage = NSLocalizedString("M_IMAGE_NOT_UPLOADED", comment: "")
        }
        if let message = errorMessage {
            AlertView().showAlert(vc: self, message: message)
        }
    }
    
    
    fileprivate func updateProfile()
    {
        if Reachability.isInternetConnected()
        {
            if let myProfileTem = self.myTempProfile
            {
                Util.showLoader()
                RequestManager.shared.createUpdateProfileRequest(profile: myProfileTem, onCompletion: { (responseJson) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            self.updateAndSaveMyProfile()
                            if self.editProfile {
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                APP_DELEGATE.openScreen(screenName: Util.getCurrentScreen().0, firstScreen: false)
                            }
                        }
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }else {
                AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
            }
        }else {            
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    
    private func updateAndSaveMyProfile()
    {
        self.myProfile?.isProfile = true
        self.myProfile?.name = self.myTempProfile?.name
        self.myProfile?.city = self.myTempProfile?.city
        self.myProfile?.dob = self.myTempProfile?.dob
        self.myProfile?.gender = self.myTempProfile?.gender
        self.myProfile?.about = self.myTempProfile?.about
        
        Util.saveProfile(myProfile: self.myProfile)
    }
    
    
    private func uploadImageOnServer(imageData: Data){
        
        if Reachability.isInternetConnected()
        {
            let fileName = "image.jpeg"
            let size = imageData.count
            let mb = Double(size) / (1024.0 * 1000)
            print("Image size in byte : \(size) in MB : \(mb)")
            
            Util.showLoader()
            self.sendUploadActionToAnalytics(imageStatus: .upload)
            RequestManager.shared.createResourceRequest(type: ResourceType.image, name: fileName, size: Int(size), onCompletion: { (responseJson) in
                
                let response =  Response.init(json: responseJson)
                if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                {
                    if let urlString = responseJson["url"].string
                    {
                        var url = urlString
                        if PUBLIC_IP {
                            url = urlString.replacingOccurrences(of: "172.20.12.111", with: "182.75.17.27")
                        }
                        RequestManager.shared.uploadResourceRequest(data: imageData, fileName: fileName, resourceUrl: url, onCompletion: { (responseJson) in
                            
                            Util.hideLoader()
                            DispatchQueue.main.async {
                                let response =  Response.init(json: responseJson)
                                if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                                {
                                    self.sendUploadActionToAnalytics(imageStatus: .success)

                                    print("Image upload success")
                                    self.profileImg.image = UIImage.init(data: imageData)
                                    self.updateImageInfoInProfile(url: url, name: fileName, size: size)
                                }else{
                                    print("Failed to upload image : \(String(describing: response.reason))")
                                }
                            }
                        }, onFailure: { (error) in
                            Util.hideLoader()
                            print("error : \(String(describing: error?.localizedDescription))")
                            AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                            self.sendUploadActionToAnalytics(imageStatus: .failed)

                        }, onProgress: { (progress) in
                            print("Upload Progress in view : \(String(describing: progress?.fractionCompleted))")
                        })
                    }else{
                        Util.hideLoader()
                        AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                        self.sendUploadActionToAnalytics(imageStatus: .failed)
                        print("Invalid URL in response from server in create resource for image upload")
                    }
                }else{
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        AlertView().showAlert(vc: self, message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                        self.sendUploadActionToAnalytics(imageStatus: .failed)
                    }
                }
                
            }) { (error) in
                print("error : \(String(describing: error?.localizedDescription))")
                Util.hideLoader()
                AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                self.sendUploadActionToAnalytics(imageStatus: .failed)
            }
        }else {
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    
    fileprivate func updateImageInfoInProfile(url : String, name : String, size : Int )
    {
        self.myProfile?.isImage = true
        let imageModel = ImageModel.init(url: url, name: name, size: size)
        self.myProfile?.imageList = [imageModel]
        Util.saveProfile(myProfile: self.myProfile)
    }
    
}



extension CreateProfileViewController : UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.nameTxt
        {
            myTempProfile?.name = self.nameTxt.text
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateProfileViewController : UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == aboutPlaceHolderText {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.backgroundColor = UIColor.white
            textViewAbout.font = UIFont.autoScale(weight: FontWeight.regular, size: 17)
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: textViewContainer.center.y-280), animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            self.setTextViewPlaceholder()
        }
        if textView == self.textViewAbout && self.textViewAbout.text != aboutPlaceHolderText
        {
            myTempProfile?.about = self.textViewAbout.text
        }
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
}


extension CreateProfileViewController : UIActionSheetDelegate
{
    @objc private func chooseImageSource()
    {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let takePhoto = UIAlertAction(title: NSLocalizedString("M_TAKE_PHOTO", comment: ""), style: .default){ (action) in
                ProfilePicManager.init(viewController: self).openImagePicker(imageSource: .camera)
            }
            optionMenu.addAction(takePhoto)
        }
        
        let choosePhoto = UIAlertAction(title: NSLocalizedString("M_CHOOSE_PHOTO", comment: ""), style: .default){ (action) in
            ProfilePicManager.init(viewController: self).openImagePicker(imageSource: .gallery)
        }
        optionMenu.addAction(choosePhoto)
        
        let cancel = UIAlertAction(title: NSLocalizedString("M_CANCEL", comment: ""), style: .cancel){ (action) in
            ProfilePicManager.init(viewController: self).openImagePicker(imageSource: .cancel)

        }
        optionMenu.addAction(cancel)
        optionMenu.modalPresentationStyle = .fullScreen
        self.present(optionMenu, animated: true, completion: nil)
    }
}


extension CreateProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.openCropViewController(image: pickedImage, picker: picker, croppingStyle : .default)
        }else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}


extension CreateProfileViewController : CropViewControllerDelegate
{
    
    private func openCropViewController(image : UIImage, picker : UIImagePickerController , croppingStyle : CropViewCroppingStyle)
    {
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
        // cropController.aspectRatioPreset = .presetCustom
        cropController.customAspectRatio = CGSize(width: 4.0, height: 5.0)
        
        // Uncomment this if you wish to provide extra instructions via a title label
        //cropController.title = "Crop Image"
        
        // -- Uncomment these if you want to test out restoring to a previous crop setting --
        //cropController.angle = 90 // The initial angle in which the image will be rotated
        //cropController.imageCropFrame = CGRect(x: 0, y: 0, width: 2848, height: 4288) //The initial frame that the crop controller will have visible.
        
        // -- Uncomment the following lines of code to test out the aspect ratio features --
        //cropController.aspectRatioPreset = .presetSquare; //Set the initial aspect ratio as a square
        cropController.aspectRatioLockEnabled = true // The crop box is locked to the aspect ratio and can't be resized away from it
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
                    cropController.modalPresentationStyle = .fullScreen
                    self.present(cropController, animated: true, completion: nil)
                })
            } else {
                picker.pushViewController(cropController, animated: true)
            }
        }
        else { //otherwise dismiss, and then present from the main controller
            picker.dismiss(animated: true, completion: {
                cropController.modalPresentationStyle = .fullScreen
                self.present(cropController, animated: true, completion: nil)
                //self.navigationController!.pushViewController(cropController, animated: true)
            })
        }
    }
    
    
    //MARK:- CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // self.updateImageViewWithImage(image, fromCropViewController: cropViewController)
        cropViewController.dismiss(animated: true, completion: nil)
        // self.uploadImageOnServer(image: image)
        
        /*
         if let data = image.jpegData(compressionQuality: 1)
         {
         let size = data.count
         let mb = Double(size) / (1024.0 * 1000)
         print("Image size in byte : \(size) in MB : \(mb)")
         
         AppFileManager().saveImage(image: image, name: "Crop")
         
         if let newdata = image.jpegData(compressionQuality: 0.1)
         {
         if let newImage = UIImage(data: newdata) {
         AppFileManager().saveImage(image: newImage, name: "crop1")
         }
         }
         }
         */
        
        if let compressedData = self.compressImage(image: image)
        {
            self.uploadImageOnServer(imageData: compressedData)
        }else{
            print("Image : Invalid image size")
            AlertView().showNotficationMessage(message: NSLocalizedString("M_WRONG_IMAGE_SIZE", comment: ""))
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.profileImg.image = image
    }
    
    fileprivate func compressImage(image : UIImage) -> Data?
    {
        if let data = image.jpegData(compressionQuality: 1)
        {
            var compressData : Data?
            let mb = Double(data.count) / (1024.0 * 1000)
            print("Image : Initial image size in mb : \(mb)")
            if mb > 5 {
                compressData = image.jpegData(compressionQuality: 0.07)
            }else if mb > 3  {
                compressData = image.jpegData(compressionQuality: 0.08)
            }else if mb > 1 {
                compressData = image.jpegData(compressionQuality: 0.12)
            }else {
                compressData = data
            }
            let newSize = Double(compressData?.count ?? 0) / (1024.0 * 1000)
            if newSize < 1 {
                print("Image : final Initial image size in mb : \(newSize)")
                return compressData
            }
        }
        return nil
    }
}


extension CreateProfileViewController
{
    func showDatePicker(){
        self.view.endEditing(true)
        
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.maximumDate = self.maxDate()
        datePicker.date = selectedDob() // Old selected DOB
        datePicker.locale = Locale.init(identifier: Util.getPhoneLangForInternal())
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: NSLocalizedString("M_DONE", comment: ""), style: .plain, target: self, action: #selector(donedatePicker))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appPrimaryColor], for: .normal)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("M_CANCEL", comment: ""), style: .plain, target: self, action: #selector(cancelDatePicker));
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appPrimaryColor], for: .normal)
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        dobTxt.inputAccessoryView = toolbar
        dobTxt.inputView = datePicker
    }
    
    func maxDate() -> Date
    {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = MIN_AGE
        return calendar.date(byAdding: components, to: currentDate) ?? Date()
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale.init(identifier: "en")
        let dateString = formatter.string(from: datePicker.date)
        myTempProfile?.dob = dateString
        self.view.endEditing(true)
        localisedDisplayDOB(dob: dateString)
    }
    
    
    private func localisedDisplayDOB(dob: String?){
        
        if let dobStr = dob {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let date = dateFormatter.date(from: dobStr)
            if let convertDate = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                formatter.locale = Locale.init(identifier: Util.getPhoneLangForInternal())
                let dateString = formatter.string(from: convertDate)
                dobTxt.text = dateString
            }
        }
        
        
        

    }
    
    
    
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    fileprivate func selectedDob() -> Date
    {
        var date = Date()
        if let dob = myTempProfile?.dob
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            date = formatter.date(from: dob) ?? Date()
        }
        return date
    }
}

extension CreateProfileViewController {
    enum ImageStatus : String{
        case upload
        case failed
        case success
    }
    
    public func sendUploadActionToAnalytics(imageStatus: ImageStatus){
        AppAnalytics.log(.image(action: imageStatus.rawValue))
        TPAnalytics.log(.image(action: imageStatus.rawValue))
    }
}



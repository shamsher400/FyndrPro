//
//  EditProfileViewController.swift
//  Fyndr
//
//  Created by Shamsher Singh on 04/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//
import UIKit
import Photos
import CropViewController
import SwiftyJSON

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileImgBgView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var cityNameView: CardView!
    @IBOutlet weak var cityNameTxt: UITextField!
    @IBOutlet weak var containerStackView: UIStackView!
    
    @IBOutlet weak var recordVideoView: CardView!
    @IBOutlet weak var videoPreviewImg: UIImageView!
    @IBOutlet weak var playVideoBtn : UIButton!
    @IBOutlet weak var playVideoView : CardView!
    @IBOutlet weak var textViewAbout: UITextView!
    @IBOutlet weak var textViewContainer: CardView!
    
    @IBOutlet weak var collectionView : DynamicHeightCollectionView!
    @IBOutlet weak var manageInterestLbl : UILabel!
    
    @IBOutlet weak var lblYourVideoProfile: UILabel!
    fileprivate var addMore = ""
    fileprivate var interestList = [SubCategory]()
    fileprivate var allInterestList = [SubCategory]()
    
    @IBOutlet weak var lblLocationTxt: UILabel!
    @IBOutlet weak var lblVideoBioTxt: UILabel!
    @IBOutlet weak var lblAboutMeTxt: UILabel!
    @IBOutlet weak var lblManageYourInterextTxt: UILabel!





    
    let aboutPlaceHolderText = NSLocalizedString("M_ABOUT", comment: "")
    
    let datePicker = UIDatePicker()
    var myProfile : Profile?
    var editProfile = false
    var myTempProfile : Profile?
    let saveBtn = UIButton.init(type: .custom)
    var mKeyBoardSize = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //navigationController?.navigationBar.setGradientBackground(colors: defaultGradientColors)
        
        self.view.setNeedsDisplay()

        self.title = NSLocalizedString("Edit Profile", comment: "")
        
        self.nameTxt.font = UIFont.autoScale()
        self.lblAboutMeTxt.font = UIFont.autoScale()
        self.lblLocationTxt.font = UIFont.autoScale()
        self.lblVideoBioTxt.font = UIFont.autoScale()
        self.lblManageYourInterextTxt.font = UIFont.autoScale()
        
        
        addGestures()
        setupNavbar()
        
        myTempProfile = Util.getProfile()
        
        lblYourVideoProfile.text = NSLocalizedString("M_YOUR_VIDEO_PROFILE", comment: "")

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupCollectionView()
        self.allInterestList = Util.getInterestList()?.subCategories ?? [SubCategory]()
        
        self.textViewAbout.delegate = self
        self.nameTxt.delegate = self    
        
        addMore = NSLocalizedString("M_ADD_MORE", comment: "")
        
        updateLocalization()
        


    }
    
    private func updateLocalization(){
        self.lblAboutMeTxt.font = UIFont.autoScale()
        self.lblLocationTxt.font = UIFont.autoScale()
        self.lblVideoBioTxt.font = UIFont.autoScale()
        self.lblManageYourInterextTxt.font = UIFont.autoScale()
        
        
        self.lblVideoBioTxt.text = NSLocalizedString("M_NAME", comment: "")
        self.lblLocationTxt.text = NSLocalizedString("M_LOCATION", comment: "")
        self.lblAboutMeTxt.text = NSLocalizedString("M_ABOUT_ME", comment: "")
        self.lblManageYourInterextTxt.text = NSLocalizedString("M_MANAGE_YOUR_INTERESR", comment: "")


        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .updateProfile))
        TPAnalytics.log(.openScreen(screen: .updateProfile))
        self.navigationController?.isNavigationBarHidden = false
        myProfile = Util.getProfile()
        self.fillLastSaveData()
        
        validateSaveBtnEneble()
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
        
        
        saveBtn.setTitle(NSLocalizedString("Save", comment: "") , for: .normal)
        saveBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 30)
        saveBtn.backgroundColor = UIColor.clear
        saveBtn.addTarget(self, action: #selector(saveChanges), for: UIControl.Event.touchUpInside)
        saveBtn.contentHorizontalAlignment = .left
        saveBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -8, bottom: 0, right: 0)
        let saveBarButton = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItem = saveBarButton
    }
    
    @objc func dismissView()
    {
        nameTxt.resignFirstResponder()
        textViewAbout.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveChanges()
    {
        validateFields()
    }
    
    
    
    
    @objc func keyboardWillShow(notification:NSNotification){
        if let userInfo = notification.userInfo
        {
            if var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            {
                keyboardFrame = self.view.convert(keyboardFrame, from: nil)
                var contentInset:UIEdgeInsets = self.scrollView.contentInset
                contentInset.bottom = keyboardFrame.size.height
                mKeyBoardSize = Int(keyboardFrame.size.height)
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
        textViewAbout.font = UIFont.autoScale(weight: FontWeight.regular, size: 15)
    }
    
    fileprivate func fillLastSaveData()
    {
        self.playVideoBtn.isHidden = true
        

        
        self.nameTxt.text = myTempProfile?.name
        self.cityNameTxt.text = myTempProfile?.city?.name
        if let about = self.myTempProfile?.about
        {
            if about.count > 0 {
                self.textViewAbout.text = about
            } else {
                self.setTextViewPlaceholder()
            }
        }else{
            self.setTextViewPlaceholder()
        }
        // Initialize intreste data
        self.interestList = myProfile?.interests ?? [SubCategory]()
        self.interestList.append(SubCategory.init(id: "add", name: addMore, thumbUrl: "addMore"))
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        
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
            }else {
                self.videoPreviewImg.image = UIImage(named: "video_rec-icon")
            }
        }
    }
    
    
    fileprivate func addGestures()
    {
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
    
    
    private func validateSaveBtnEneble(){
        if myTempProfile?.name == myProfile?.name && myTempProfile?.city?.id == myProfile?.city?.id && (myTempProfile?.about == myProfile?.about ) {
            saveBtn.isHidden = true
        }else {
            saveBtn.isHidden = false
        }
    
    }
    
    
    fileprivate func validateFields()
    {
        var errorMessage : String?
        
        if myProfile?.imageList?.first?.url != nil {
            
            if Util.isStringNotEmpty(string: myTempProfile?.name)
            {
                if myTempProfile?.city != nil
                {
                    self.updateProfile()
                }else{
                    errorMessage = NSLocalizedString("M_INVALID_CITY", comment: "")
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
                            self.dismiss(animated: true, completion: nil)
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



extension EditProfileViewController : UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.nameTxt
        {
            myTempProfile?.name = self.nameTxt.text
            
        }
        
        validateSaveBtnEneble()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditProfileViewController : UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == aboutPlaceHolderText {
            textView.text = ""
            textView.textColor = UIColor.black
            textViewAbout.font = UIFont.autoScale(weight: FontWeight.regular, size: 17)
        }
        scrollKeyboard()
        print("textViewContainer.center.y \(textViewContainer.center.y)")
        print("headerHeightConstraint.constant \(headerHeightConstraint.constant)")
//        let yOffset = textViewContainer.center.y + headerHeightConstraint.constant - 230
    }
    
    private func scrollKeyboard(){
        print("textViewContainer.center.y \(textViewContainer.center.y)")
        var height = 0
        if #available(iOS 11.0, *) {
            let guide = view.safeAreaLayoutGuide
            height = Int(guide.layoutFrame.size.height)
        } else {
            height = Int(view.frame.height)
        }
        print("mainView.height \(height)")
        let remainViewHeight = height - mKeyBoardSize

        let textViewCenterSize = textViewContainer.center.y
        if remainViewHeight <  Int(textViewCenterSize + headerHeightConstraint.constant) {
            var scrollPossition = remainViewHeight - Int(textViewCenterSize + headerHeightConstraint.constant)
            if 0 > scrollPossition {
                scrollPossition = scrollPossition - (scrollPossition * 2)
            }
            scrollView.setContentOffset(CGPoint(x: 0, y:  scrollPossition + 50), animated: true)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == self.textViewAbout && self.textViewAbout.text != aboutPlaceHolderText
        {
            myTempProfile?.about = self.textViewAbout.text
        }else if textView == self.textViewAbout {
            myTempProfile?.about = ""
        }
        validateSaveBtnEneble()

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
        validateSaveBtnEneble()
    }
}


extension EditProfileViewController : UIActionSheetDelegate
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


extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.openCropViewController(image: pickedImage, picker: picker, croppingStyle : .default)
        }else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}


extension EditProfileViewController : CropViewControllerDelegate
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

extension EditProfileViewController {
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

extension EditProfileViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    fileprivate func setupCollectionView()
    {
        self.collectionView.register(UINib.init(nibName: "InterestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellIdentifier")
        
        let flowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
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
        if subCategory.thumbUrl == "addMore"
        {
            return ("addMore","addMore")
        }
        let subCategory = self.allInterestList.filter { $0.id == subCategory.id }
        return (subCategory.first?.thumbUrl,subCategory.first?.selectedThumbUrl)
    }
    
    
    fileprivate func openInterestSelectionView()
    {
        let interestViewController = UIStoryboard.getViewController(identifier: "InterestViewController") as! InterestViewController
        interestViewController.editProfile = true
        interestViewController.myProfile = self.myProfile
        self.navigationController?.pushViewController(interestViewController, animated: true)
    }
}




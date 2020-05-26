//
//  OTPViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 03/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVPinView

class OTPViewController: UIViewController {
    
    @IBOutlet weak var verifyButton : UIButton!
    @IBOutlet weak var messageLbl : UILabel!
    @IBOutlet weak var lblDintFound: UILabel!
    @IBOutlet weak var btnResendOtp: UIButton!
    
    @IBOutlet weak var lblWaitTimer: UILabel!
    @IBOutlet weak var viewPasswordWithText: SVPinView!
    
    var msisdn : String!
    var callingCode : String!
    var waitTimeInSecond = 180
    var timer = Timer()
    
    var otpText :String?
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = NSLocalizedString("Sign Up", comment: "")
        if let msisdn = msisdn {
            self.messageLbl.text = NSLocalizedString("M_OTP_MESSAGE_WITH_NUMBER", comment: "") + self.getXXFormatNumber(msisdn: msisdn)
        }else{
            self.messageLbl.text = NSLocalizedString("M_OTP_MESSAGE_WITHOUT_NUMBER", comment: "")
        }
        messageLbl.font = UIFont.autoScale(weight: .regular, size: 15)
        verifyButton.titleLabel?.font = UIFont.autoScale(weight: .semibold, size: 17)
        lblDintFound.font = UIFont.autoScale(weight: .regular, size: 14)
        btnResendOtp.titleLabel?.font = UIFont.autoScale(weight: .regular, size: 14)
        lblWaitTimer.font = UIFont.autoScale(weight: .regular, size: 17)

        lblDintFound.text = NSLocalizedString("M_DIDNT_GET_OTP", comment: "")
        btnResendOtp.setTitle(NSLocalizedString("M_RESENT_OTP", comment: ""), for: .normal)
        
//        self.handleOtpView()
        
        
        
        startTimer()
        
        viewPasswordWithText.shouldSecureText = false
        viewPasswordWithText.pinLength = 6
        self.viewPasswordWithText.didFinishCallback = { pin in
            print("The pin entered is \(pin)")
            self.otpText = pin
        }
        
        
        viewPasswordWithText.didChangeCallback = { pin in
            print("The pin entered did is \(pin)")
            self.otpText = pin

        }
    }
    
    
    
    private func startTimer() {
        print(" startTimer()")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        waitTimeInSecond  = waitTimeInSecond - 1
        
        if waitTimeInSecond >= 0 {
            lblWaitTimer.isHidden = false
            btnResendOtp.isHidden = true
            let timeInMInStr = "0\(waitTimeInSecond / 60)"
            let timeInSecond = waitTimeInSecond % 60
            var timeInStr = "";
            if timeInSecond >= 10 {
                timeInStr = "\(timeInSecond)"
            }else {
                timeInStr = "0\(timeInSecond)"
            }
            lblWaitTimer.text = "\(NSLocalizedString("Wait", comment: "")) \(timeInMInStr):\(timeInStr)"
        }else {
            lblWaitTimer.isHidden = true
            btnResendOtp.isHidden = false
            timer.invalidate()
        }
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem?.title = ""
        AppAnalytics.log(.openScreen(screen: .otpScreen))
        TPAnalytics.log(.openScreen(screen: .otpScreen))
    }
    
    override func viewWillLayoutSubviews() {
        verifyButton.setGradient(colors: defaultGradientColors)
    }
    
    fileprivate func getXXFormatNumber(msisdn : String) -> String
    {
        if msisdn.count > 4 {
            return String(repeating: "X", count: msisdn.count - 4) + msisdn[String.Index(encodedOffset: msisdn.count-4)..<String.Index(encodedOffset: msisdn.count)]
        }
        return msisdn
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func btnResendOtp(_ sender: Any) {
        self.resendOtp()
    }
    
    //MARK:- Button Action
    @IBAction func loginButtonAction(_ sender : UIButton)
    {
//        self.otpTxt.resignFirstResponder()
        self.view.endEditing(true)
        processOtp()
    }
    
    
    private func processOtp()
    {
        var errorMessage : String?
        
        if let otp = otpText
        {
            if Util.isStringNotEmpty(string: otp) && Util.isNumberContainsSpecialChar(number: otp) && otp.count == OTP_LENGTH
            {
                varifyOtp(otp: otp)
            }else{
                errorMessage = NSLocalizedString("M_INVALID_OTP", comment: "")
            }
        }else{
            errorMessage = NSLocalizedString("M_INVALID_OTP", comment: "")
        }
        
        if let message = errorMessage
        {
            AlertView().showAlert(vc: self, message: message)
        }
    }
    
    private func varifyOtp(otp : String)
    {
        if Reachability.isInternetConnected()
        {
            if let msisdn = self.msisdn, let callingCode = callingCode
            {
                Util.showLoader()
                
                let numberWithCallingCode = "\(callingCode)\(msisdn)".removePlus()
                
                RequestManager.shared.registrationRequest(numberWithCallingCode: numberWithCallingCode, otp: otp, registrationMethod: .OTP, onCompletion: { (responseJson) in
                    
                    DispatchQueue.main.async {
                        print("varifyOtp()   \(responseJson)")
                        Util.hideLoader()
                        
                        let response = RegistrationResponse.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            self.processRegistartionResponse(response: response)
                        }else{
                            if let reason = response.reason {
                                self.sendSubmitOtpFailedOtp(msisdn: msisdn, reason: reason)
                                AlertView().showAlert(vc: self, message: reason)
                            }else
                            {
                                self.sendSubmitOtpFailedOtp(msisdn: msisdn, reason: "Not found")
                                AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
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
    
    
    fileprivate func processRegistartionResponse(response : RegistrationResponse)
    {
        var myProfile = Util.getProfile()
        
        if response.isProfile
        {
            myProfile = response.profile
        }else{
            myProfile = Profile.init(json: JSON())
            myProfile?.uniqueId = response.uniqueId
            myProfile?.jabberId = response.jabberId
            myProfile?.password = response.password
        }
        myProfile?.isRegister = true
        
        if let callingCode = callingCode, let msisdn = msisdn {
            myProfile?.msisdn = "\(callingCode)-\(msisdn)"
        }
        Util.saveProfile(myProfile: myProfile)
        
        if let token = response.token {
            UserDefaults.standard.set(token, forKey: USER_DEFAULTS.AUTH_TOKEN)
            UserDefaults.standard.synchronize()
        }
        if let uniqueId = response.uniqueId {
            UserDefaults.standard.set(uniqueId, forKey: USER_DEFAULTS.USER_ID)
            UserDefaults.standard.synchronize()
            APP_DELEGATE.openScreen(screenName: Util.getCurrentScreen().0, firstScreen: false)
        }
        
        Util.setChatConfiguration(chatConfiguration: response.chatConfiguration)
        Util.setSipConfiguration(sipConfiguration: response.sipConfiguration)
        
        APP_DELEGATE.initChatManager(myProfile: myProfile, chatConfiguration: response.chatConfiguration)
        NotificationManager.shared.registerForServerNotifications(pushToken: nil)
        
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.GET_BOOKMARK)
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.GET_BLOCKLIST)
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.GET_CHAT_HISTORY)
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.RECENT_SUCCESS)
        UserDefaults.standard.set(true, forKey: USER_DEFAULTS.CONNECTIONS_SUCCESS)
        UserDefaults.standard.set(self.msisdn, forKey: USER_DEFAULTS.MSISDN_CODE)

        UserDefaults.standard.synchronize()
        
    }
}

extension OTPViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else {
            return true
        }
        let newLength = text.count + string.count - range.length

        //        if newLength == OTP_LENGTH
        //        {
        //            self.processOtp()
        //            return false
        //        }
        return newLength <= OTP_LENGTH
    }



//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        otpTxt.layer.borderColor = UIColor.appPrimaryColor.cgColor
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        otpTxt.layer.borderColor = UIColor.borderColor.cgColor
//    }
}

extension OTPViewController : SendOtpDelegate{
    
    
    
    private func resendOtp()
    {
        Util.showLoader()
        let sendOtp = SendOtpPresenter()
        sendOtp.setDelegate(delegate: self)
        sendOtp.requestOtp(msisdn: self.msisdn, callingCode: callingCode)
        resendOtpAnalytics(msisdn: msisdn, countryCode: callingCode)
        
    }
    
    
    
    func onFailed(message: String, nonOtp: Bool?) {
        DispatchQueue.main.async {
            Util.hideLoader()
            let otpUrl = SendOtpRequest.URLParams.APIPath
            if let urlString = otpUrl.components(separatedBy: "/").last {
                self.failedApiAnalytics(api: urlString, reason: message)
            }
            AlertView().showAlert(vc: self, message: message)
        }
    }
    
    func onSuccess(msisdn: String, callingCode: String, message: String?) {
        
        DispatchQueue.main.async {
            Util.hideLoader()
            
            guard let message = message else {
                return
            }
            AlertView().showAlert(vc: self, message: message)
        }
    }
}


// initilize And process otp view




extension OTPViewController {
    
    private func resendOtpAnalytics(msisdn: String, countryCode: String){
        startTimer()
        AppAnalytics.log(.resendOtp)
        TPAnalytics.log(.resendOtp)

    }
    
    private func sendSubmitOtpFailedOtp(msisdn: String, reason: String){
        let url = RegistrationRequest.URLParams.APIPath
        if let fUrl = url.components(separatedBy: "/").last{
            AppAnalytics.log(.apiFailure(api: fUrl, reason: reason))
            TPAnalytics.log(.apiFailure(api: fUrl, reason: reason))

        }
    }
    
    private func failedApiAnalytics(api: String ,reason: String){
        AppAnalytics.log(.apiFailure(api: api, reason: reason))
        TPAnalytics.log(.apiFailure(api: api, reason: reason))

    }
}


// Initilization OTP View
//extension OTPViewController {
//
//
//
//    private func handleOtpView(){
//        lblOtpFirst.delegate = self
//        lblOtpSecond.delegate = self
//        lblOtpThird.delegate = self
//        lblOtpFour.delegate = self
//        lblOtpFive.delegate = self
//        lblOtpSix.delegate = self
//        initilizeOtpView()
//        otpTxt.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
//
//    }
//
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        if textField.text?.count == 0 {
//            initilizeOtpView()
//            return
//        }
//        let otpCount = textField.text?.count ?? 0
////        let otpLastChar =  String(textField.text!.last! )
////        updateOtpView(otpCount: otpCount)
////        filledOtpInView(otpCount: otpCount, otpChar: otpLastChar)
//    }
//
//
//
//    private func initilizeOtpView() {
//        lblOtpFirst.becomeFirstResponder()
//        lblOtpFirst.text = ""
//        lblOtpSecond.text = ""
//        lblOtpThird.text = ""
//        lblOtpFour.text = ""
//        lblOtpFive.text = ""
//        lblOtpSix.text = ""
//        lblOtpFirst.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.50)
//        lblOtpSecond.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//        lblOtpThird.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//        lblOtpFour.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//        lblOtpFive.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//        lblOtpSix.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//    }
//
//
//    private func updateOtpView(otpCount: Int){
//        switch otpCount {
//        case 0:
//            initilizeOtpView()
//            break
//        case 1:
//            lblOtpSecond.becomeFirstResponder()
//
//            lblOtpSecond.text = ""
//            lblOtpThird.text = ""
//            lblOtpFour.text = ""
//            lblOtpFive.text = ""
//            lblOtpSix.text = ""
//            lblOtpSecond.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.50)
//            lblOtpThird.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            lblOtpFour.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            lblOtpFive.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            lblOtpSix.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            break
//        case 2:
//            lblOtpThird.becomeFirstResponder()
//
//            lblOtpThird.text = ""
//            lblOtpFour.text = ""
//            lblOtpFive.text = ""
//            lblOtpSix.text = ""
//            lblOtpThird.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.50)
//            lblOtpFour.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            lblOtpFive.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            lblOtpSix.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            break
//        case 3:
//            lblOtpFour.becomeFirstResponder()
//
//            lblOtpFour.text = ""
//            lblOtpFive.text = ""
//            lblOtpSix.text = ""
//            lblOtpFour.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.50)
//            lblOtpFive.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            lblOtpSix.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            break
//        case 4:
//            lblOtpFive.becomeFirstResponder()
//
//            lblOtpFive.text = ""
//            lblOtpSix.text = ""
//            lblOtpFive.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.50)
//            lblOtpSix.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.20)
//            break
//        case 5:
//            lblOtpSix.becomeFirstResponder()
//            lblOtpSix.text = ""
//            lblOtpSix.backgroundColor = Util.hexStringToUIColor(hexColor: "4999DA", opicity: 0.50)
//            break
//        case 6:
//            self.otpTxt.resignFirstResponder()
//            break
//        default:
//            print("case not found for thi case \(otpCount)")
//        }
//    }
//
//
//    private func filledOtpInView(otpCount: Int, otpChar: String){
//        switch otpCount {
//        case 0:
//            initilizeOtpView()
//            break
//        case 1:
//            lblOtpFirst.text = otpChar
//
//            break
//        case 2:
//            lblOtpSecond.text = otpChar
//            break
//        case 3:
//            lblOtpThird.text = otpChar
//            break
//        case 4:
//            lblOtpFour.text = otpChar
//            break
//        case 5:
//            lblOtpFive.text = otpChar
//            break
//        case 6:
//            lblOtpSix.text = otpChar
//            break
//        default:
//            print("case not found for thi case \(otpCount)")
//        }
//    }
//}
//
//extension OTPViewController : UITextFieldDelegate
//{
//
//
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        print("Backspace was pressed")
//
//        return true
//    }
//
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//
//        if let char = string.cString(using: String.Encoding.utf8) {
//            let isBackSpace = strcmp(char, "\\b")
//            if (isBackSpace == -92) {
//                print("Backspace was pressed")
//            }
//        }
//
//        guard let text = textField.text else {
//            return true
//        }
//
////        textField.resignFirstResponder()
//
//        let newLength = text.count + string.count - range.length
//        if newLength == 1
//        {
//            // Move to next
//            if textField == self.lblOtpFirst
//            {
//                self.lblOtpSecond.becomeFirstResponder()
//            }else  if textField == self.lblOtpSecond
//            {
//                self.lblOtpThird.becomeFirstResponder()
//            }else if textField == self.lblOtpThird
//            {
//                self.lblOtpFour.becomeFirstResponder()
//            }else if textField == self.lblOtpFour
//            {
//                self.lblOtpFive.becomeFirstResponder()
//            }else if textField == self.lblOtpFive
//            {
//                self.lblOtpSix.becomeFirstResponder()
//            }
//
//
//
//        }else
//        {
//            if textField == self.lblOtpSecond
//            {
//                self.lblOtpFirst.becomeFirstResponder()
//            }else  if textField == self.lblOtpThird
//            {
//                self.lblOtpSecond.becomeFirstResponder()
//            }else if textField == self.lblOtpFour
//            {
//                self.lblOtpThird.becomeFirstResponder()
//            }else if textField == self.lblOtpFive
//            {
//                self.lblOtpFour.becomeFirstResponder()
//            }else if textField == self.lblOtpSix
//            {
//                self.lblOtpFive.becomeFirstResponder()
//            }
//            // Move to prev
//
//        }
//        return true
//    }
//
//
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//    }
//}

//
//  RegistrationViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 26/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import DropDown

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var lblOrText: UILabel!
    @IBOutlet weak var lblOtpeHint: UILabel!
    @IBOutlet weak var loginButton : UIButton!
    @IBOutlet weak var otherLoginBtn : UIButton!
    @IBOutlet weak var mobileNumberTxt : UITextField!
    
    @IBOutlet weak var countryCodeView : UIView!
    @IBOutlet weak var countryCodeLbl : UILabel!
    @IBOutlet weak var countyFlag : UIImageView!
    
    let countryDropDown = DropDown()
    var countryList = [Country]()
    var seletedCountry : Country? = nil
    var appConfig : AppConfiguration?
    
    var userMsisdn = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.title = NSLocalizedString("Sign Up", comment: "")
        lblOtpeHint.font = UIFont.autoScale(weight: .regular, size: 13)
        lblOtpeHint.text = NSLocalizedString("M_OTP_WILL_SEND", comment: "")
        appConfig = Util.getAppConfig()
        self.setupCountryDropDown()
        
        mobileNumberTxt.font = UIFont.autoScale()
        countryCodeLbl.font = UIFont.autoScale()
        lblOrText.font = UIFont.autoScale(weight: .regular, size: 23)
        
        lblOrText.text = NSLocalizedString("OR", comment: "")

        loginButton.titleLabel?.font = UIFont.autoScale(weight: .semibold, size: 17)
        loginButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        otherLoginBtn.titleLabel?.font = UIFont.autoScale(weight: .semibold, size: 17)
        otherLoginBtn.setTitle(NSLocalizedString("M_OTHER_SIGNIN", comment: ""), for: .normal)
        mobileNumberTxt.placeholder = NSLocalizedString("M_ENTER_PHONE_NUMBER", comment: "")
        
        
        if userMsisdn != "" && userMsisdn.hasPrefix(Util.getUserCountryCode().removePlus()) {
            userMsisdn = String(userMsisdn.dropFirst(2))
            mobileNumberTxt.text = userMsisdn
            
        }
    }
        

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    //    self.navigationItem.backBarButtonItem?.title = ""
        AppAnalytics.log(.openScreen(screen: .register))
        TPAnalytics.log(.openScreen(screen: .register))
    }
    
    override func viewWillLayoutSubviews() {
        loginButton.setGradient(colors: defaultGradientColors)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK:- Button Action
    @IBAction func loginButtonAction(_ sender : UIButton)
    {
        var errorMessage : String?
        let input = mobileNumberTxt.text!
        if Util.isNumberContainsSpecialChar(number: input)
        {
            if input.count < MSISDN_MAXIMUM_LENGTH && input.count >  MSISDN_MINIMUM_LENGTH
            {
                self.view.endEditing(true)
                showConformationDialog()            }else{
                // Number is too long
                errorMessage = NSLocalizedString("M_MAX_LENGTH_EXCEEDED", comment: "")
            }
        }else {
            errorMessage = NSLocalizedString("M_INVALID_NUMBER", comment: "")
        }
        if let message = errorMessage
        {
            AlertView().showAlert(vc: self, message: message)
        }
    }
    
    
    @IBAction func otherLoginBtn(_ sender : UIButton)
    {
        openSocialLogin()
    }
    
    
    
    private func validateNumber()
    {
        var errorMessage : String?
        
        if Util.isStringNotEmpty(string: mobileNumberTxt.text)
        {
            let input = mobileNumberTxt.text!
            
            if Util.isNumberContainsSpecialChar(number: input)
            {
                if input.count < MSISDN_MAXIMUM_LENGTH && input.count >  MSISDN_MINIMUM_LENGTH
                {
                    self.initiateLogin(msisdn: input)
                }else{
                    // Number is too long
                    errorMessage = NSLocalizedString("M_MAX_LENGTH_EXCEEDED", comment: "")
                }
            }else {
                errorMessage = NSLocalizedString("M_INVALID_NUMBER", comment: "")
            }
        }else{
            errorMessage = NSLocalizedString("M_EMPTY_NUMBER", comment: "")
        }
        
        if let message = errorMessage
        {
            AlertView().showAlert(vc: self, message: message)
        }
    }
    
    
}

extension RegistrationViewController
{
    @objc func selectCountry() {
        countryDropDown.show()
    }
    
    func setupCountryDropDown() {
        
        guard let countryList = Util.getCountryList() else {
            return
        }
        self.countryList = countryList
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCountry))
//        self.countryCodeView.addGestureRecognizer(tapGesture)
        
        countryDropDown.anchorView = self.countryCodeView
        countryDropDown.width = 250
        countryDropDown.bottomOffset = CGPoint(x: 0, y: 50)

        var countryNames = [String]();
        let countryNamesList = countryList.map({(country : Country) -> String? in country.name})
        countryNames = countryNamesList.compactMap({ return $0 })
        
        countryDropDown.dataSource = countryNames
        countryDropDown.cellNib = UINib(nibName: "CountryListViewCell", bundle: nil)
        countryDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? CountryListViewCell else { return }
            
            // Setup your custom UI components
            if self.countryList.count > index {
                let countryObj = self.countryList[index]
                cell.countryCode.text = countryObj.dialCode
                cell.countryFlag.image = UIImage.init(named: (countryObj.code?.lowercased())!)
            }
        }
        // Action triggered on selection
        countryDropDown.selectionAction = { [unowned self] (index, item) in
            print("Selected item: \(item) at index: \(index)")
            
            if self.countryList.count > index {
                let countryObj = self.countryList[index]
                self.updateCurrentCountryInfo(countryObj: countryObj)
            }
        }
        setCurrentCountryInfo()
        
    }
    
    private func updateCurrentCountryInfo(countryObj : Country ){
        
        if( self.seletedCountry?.dialCode != nil && self.seletedCountry?.dialCode != countryObj.dialCode){
            self.countryCodeLbl.text = countryObj.dialCode!
            self.seletedCountry = Country(name: countryObj.name, dialCode: countryObj.dialCode, code: countryObj.code)
        }else{
            self.countryCodeLbl.text = countryObj.dialCode!
        }
        if countryObj.code != nil {
            self.countyFlag.image = UIImage(named: (countryObj.code)!.lowercased())
        }
        Util.setUserCountryCode(countryCode: countryObj.dialCode ?? "")
    }
    
    private func setCurrentCountryInfo(){
        
        let currentCountryCode = Util.getUserCountryCode()
        let currectCountry = self.getCountyWithCountryCode(countryCode: currentCountryCode)
        
        if (currectCountry?.name != nil && currectCountry?.dialCode != nil && currectCountry?.code != nil){
            self.countryCodeLbl.text = currectCountry?.dialCode
            self.countyFlag.image = UIImage(named: (currectCountry?.code)!.lowercased())
            self.seletedCountry = Country(name: currectCountry?.name, dialCode: currectCountry?.dialCode, code: currectCountry?.code)
        }else{
            self.countryCodeLbl.text = DEFAULT_COUNTY_CALLING_CODE
            self.countyFlag.image = UIImage(named: DEFAULT_COUNTY_CODE.lowercased())
            self.seletedCountry = Country(name: DEFAULT_COUNTY_NAME, dialCode: DEFAULT_COUNTY_CALLING_CODE, code: DEFAULT_COUNTY_CODE)
        }
    }
    
    private func getCountyWithCountryCode(countryCode : String) -> Country?{
        var currentCountry = Country(name: nil, dialCode: nil, code: nil)
        
        if self.countryList.count > 0 {
            let filteredList = self.countryList.filter( { return $0.dialCode == countryCode } )
            
            if filteredList.count > 0 {
                currentCountry = filteredList.first!
            }
        }
        return currentCountry
    }
}

extension RegistrationViewController : SendOtpDelegate{
    
    private func initiateLogin(msisdn : String)
    {
        
        if let callingCode = self.seletedCountry?.dialCode
        {
            Util.showLoader()
            let sendOtp = SendOtpPresenter()
            sendOtp.setDelegate(delegate: self)
            sendOtp.requestOtp(msisdn: msisdn, callingCode: callingCode)
            sendOtpAnalytics(msisdn: msisdn, countryCode: callingCode)
        }else {
            AlertView().showAlert(vc: self, message: NSLocalizedString("M_INVALID_CALLING_CODE", comment: ""))
        }
    }
    
    
    
    func onFailed(message: String, nonOtp: Bool?) {
        DispatchQueue.main.async {
            Util.hideLoader()
            
            if nonOtp ?? false {
                self.showRequestFailNoMpt(message: message)
            }else {
                AlertView().showAlert(vc: self, message: message)
            }
        }
    }
    
    func onSuccess(msisdn: String, callingCode: String, message: String?) {
        
        DispatchQueue.main.async {
            Util.hideLoader()
            guard let otpViewController = UIStoryboard.getViewController(identifier: "OTPViewController") as? OTPViewController else
            {
                return
            }
            otpViewController.msisdn = msisdn
            otpViewController.callingCode = callingCode
            self.navigationController?.pushViewController(otpViewController, animated: true)
        }
    }
}

extension RegistrationViewController : AlertViewDelegate{
    
    private func showConformationDialog(){
        let alertView = AlertView.init()
        alertView.delegate = self
        let alertMessage = NSLocalizedString("M_MAKE_SURE_YOU_ARE_USING_MPT", comment: "")
        alertView.showAlert(vc: self, title: "", message: alertMessage, okButtonTitle: NSLocalizedString("Skip", comment: ""), cancelButtonTitle: NSLocalizedString("Continue", comment: ""), tag: 9)
    }
    
    
    
    private func showRequestFailNoMpt(message: String){
        let alertView = AlertView.init()
        alertView.delegate = self
        alertView.showAlert(vc: self, title: "", message: message, okButtonTitle: NSLocalizedString("M_SOCIAL_LOGIN", comment: ""), cancelButtonTitle: NSLocalizedString("edit", comment: ""), tag: 8)
    }
    
    
    private func openSocialLogin() {
        self.performSegue(withIdentifier: "SocialLoginVC", sender: self)
    }
    
    
    
    
    func okButtonAction(tag: Int) {
        if tag == 9 || tag == 8{
            openSocialLogin()
        }
    }
    
    func cancelButtonAction(tag: Int) {
        if tag == 9 {
            validateNumber()
        }
    }
}




extension RegistrationViewController {
    private func sendOtpAnalytics(msisdn: String, countryCode: String){
        AppAnalytics.log(.otpRequest(msisdn: msisdn, countryCode: countryCode))
    }
}

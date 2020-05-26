//
//  IntroViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Firebase

enum RequestStatus {
    case idea
    case inProgress
    case complated
}

enum ConfigurationType : String {
    case city = "city"
    case interest = "interest"
    case defaultType = "default"
    case basic = "basic"
}

class IntroViewController: UIViewController {
    
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var pageControl : UIPageControl!
    @IBOutlet weak var continueButton : GradientButton!
    
    @IBOutlet weak var btnChangeLanguage : UIButton!

    
    fileprivate var animationView: AnimationView?
    fileprivate var animationViewBg: UIView?
    
    fileprivate var slidViews:[SlidView] = [];
    fileprivate var timer : Timer?
    fileprivate let tickRate = 3.0
    fileprivate let fireAtfter = 5.0
    
    fileprivate var requestStatus = RequestStatus.idea
    fileprivate var waitingForRequestToComplate = false
    fileprivate var appConfig : AppConfiguration?
    fileprivate var appHeData : AppHeData?
    private var userMsisdn : String?
    
    private var checkHeUrl = ""
    private var isHeRequested = false
    var selectedLanguage = Bundle.getCurrentLanguage()


    fileprivate let TAG = "Intro : "
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initDataSource()
        setupSlideScrollView()
        //startTimer()
        Util.setDefaultCountryCode()
        requestStatus = .inProgress
        getAppConfigurationFromServer(blocking : false)
        continueButton.setTitle(NSLocalizedString("M_START_FYNDING", comment: ""), for: .normal)
        continueButton.titleLabel?.font = UIFont.autoScale(weight: .semibold, size: 17)
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        AppAnalytics.log(.openScreen(screen: .intro))
        TPAnalytics.log(.openScreen(screen: .intro))
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.isNavigationBarHidden = true
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
    }
    @IBAction func startButtonAction(_ sender : UIButton)
    {
        if Util.getAppConfig() != nil && self.isHeRequested{
            takeUserTypeAction()
        }else {
            if requestStatus == .inProgress {
                Util.showLoader()
                self.waitingForRequestToComplate = true
            }else {
                getAppConfigurationFromServer(blocking : true)
            }
        }
    }
    
    
    private func goToHeFlow () {
        registrationMetodEvent(methods: RegistrationMethods.HE.rawValue)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    private func openOtpLogin() {
        self.performSegue(withIdentifier: "login", sender: self)
    }
    
    fileprivate func registerUser(msisdn : String, callingCode : String, registrationMethod : RegistrationMethods)
    {
        if Reachability.isInternetConnected()
        {
            let numberWithCallingCode = "\(callingCode)\(msisdn)".removePlus()
            Util.setUserCountryCode(countryCode: callingCode)
            RequestManager.shared.registrationRequest(numberWithCallingCode: numberWithCallingCode, otp: "", registrationMethod: registrationMethod , onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    
                    let response = RegistrationResponse.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        self.processRegistartionResponse(response: response, msisdn: msisdn, callingCode: callingCode)
                    }else{
                        self.stopAnimation()
                        self.showSystemError(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }) { (error) in
                self.stopAnimation()
                print("\(self.TAG) error : \(String(describing: error?.localizedDescription))")
                self.showSystemError(message: NSLocalizedString("M_LOGIN_ERROR", comment: ""))
            }
        }else {
            self.stopAnimation()
            self.showSystemError(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    
    fileprivate func processRegistartionResponse(response : RegistrationResponse, msisdn : String, callingCode : String)
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
        myProfile?.isInterest = true
        myProfile?.isRegister = true
        myProfile?.msisdn = "\(callingCode)-\(msisdn)"
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
        
        UserDefaults.standard.synchronize()
    }

    fileprivate func getAppConfigurationFromServer(blocking : Bool)
    {
        if Reachability.isInternetConnected()
        {
            RequestManager.shared.appConfigurationRequest(configurationType : .defaultType ,onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        let appConfig = AppConfiguration.init(json: responseJson)
                        Util.saveAppConfig(configuration: appConfig)
                        
                        let interestList = InterestList.init(interests: appConfig.interests)
                        Util.saveInterestList(interestList: interestList)
                        
                        CityListManager.shared.initWithJson(json: responseJson)
                        
                        if let heUrl = responseJson["heUrl"].string {
                            self.checkHeUrl = heUrl
                            self.validateHeurl(blocking: false)
                        }
                    }
                    else if self.waitingForRequestToComplate {
                        self.showSystemError(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
                
            }) { (error) in
                print("\(self.TAG) error : \(String(describing: error?.localizedDescription))")
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    self.requestStatus = .complated
                    
                    if self.waitingForRequestToComplate
                    {
                        self.showSystemError(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }
            
        }else{
            self.requestStatus = .complated
            self.showSystemError(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    private func validateHeurl(blocking : Bool) {
        if checkHeUrl != "" {
            checkHeRequest(blocking: blocking)
        }else {
            if blocking {
                AlertView().showAlert(vc: self, title: "", message: NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
            }
        }
    }
    
    
    private func takeUserTypeAction(){
        if self.userMsisdn != nil && self.userMsisdn != "" {
            registerUser(registrationMethod: .HE)
            goToHeFlow()
        }else {
            openOtpLogin()
        }
    }
    
    
    fileprivate func checkHeRequest(blocking : Bool)
    {
        if Reachability.isInternetConnected()
        {
            RequestManager.shared.checkHE(urlString: self.checkHeUrl, onCompletion: {
                (responseJson) in
                self.isHeRequested = true
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    let heData = AppHeData.init(json: responseJson)
                    print("HE Response data \(responseJson)")
                    if heData.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        if let userNumber = heData.msisdn {
                            self.userMsisdn = userNumber
                        }
                        self.requestStatus = .complated
                        if self.waitingForRequestToComplate{
                            self.takeUserTypeAction()
                        }
                    } else if self.waitingForRequestToComplate {
                        self.takeUserTypeAction()
                    }
                }
                
            }) { (error) in
                print("\(self.TAG) error : \(String(describing: error?.localizedDescription))")
                self.isHeRequested = true
                DispatchQueue.main.async {
                    Util.hideLoader()
                    self.requestStatus = .complated
                    
                    if self.waitingForRequestToComplate
                    {
                        self.showSystemError(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }
            
        }else{
            self.requestStatus = .complated
            self.showSystemError(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    
    fileprivate func showSystemError(message : String)
    {
        AlertView().showAlert(vc: self, title: "", message: message, okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
    }
}

extension IntroViewController {
    
    private func initDataSource()
    {
        let slid1 = SliderItem.init(title:NSLocalizedString("M_EXPLORE_TITLE", comment: ""), desc:NSLocalizedString("M_EXPLORE_DESC", comment: ""), imageName: "Onboarding1")
        slidViews.append(getSlidViewWithSlidItem(slidItem: slid1))
        
        let slid2 = SliderItem.init(title:NSLocalizedString("M_CONNECT_TITLE", comment: ""), desc:NSLocalizedString("M_CONNECT_DESC", comment: ""), imageName: "Onboarding2")
        slidViews.append(getSlidViewWithSlidItem(slidItem: slid2))
        
        let slid3 = SliderItem.init(title:NSLocalizedString("M_PLAY_TITLE", comment: ""), desc:NSLocalizedString("M_PLAY_DESC", comment: ""), imageName: "Onboarding3")
        slidViews.append(getSlidViewWithSlidItem(slidItem: slid3))
    }
    
    private func getSlidViewWithSlidItem(slidItem : SliderItem) -> SlidView
    {
        guard  let slidView = Bundle.main.loadNibNamed("SlidView", owner: self, options: nil)?.first as? SlidView else {
            return SlidView()
        }
        slidView.initWithSlidItem(sliderItem: slidItem)
        return slidView
    }
    
    func setupSlideScrollView() {
        
        pageControl.numberOfPages = slidViews.count
        pageControl.currentPage = 0
        
        scrollView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 0.8)
        let scrollViewFrame = scrollView.frame
        scrollView.contentSize = CGSize(width: scrollViewFrame.width * CGFloat(slidViews.count), height: scrollViewFrame.height)
        
        scrollView.backgroundColor = UIColor.red
        
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        
        for i in 0 ..< slidViews.count {
            slidViews[i].frame = CGRect(x: scrollViewFrame.width * CGFloat(i), y: 0, width: scrollViewFrame.width, height: scrollViewFrame.height)
            scrollView.addSubview(slidViews[i])
        }
    }
    
    private func startTimer()
    {
        timer = Timer.init(fireAt: Date.init().addingTimeInterval(fireAtfter), interval: tickRate, target: self, selector: #selector(onTimerTick), userInfo: nil, repeats: true)
        // Make the timer efficient.
        timer?.tolerance = 0.15
        // Helps UI stay responsive even with timer.
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    private func stopTimer()
    {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func onTimerTick(timer: Timer) -> Void {
        
        if pageControl.currentPage >= self.slidViews.count - 1
        {
            pageControl.currentPage = 0
        }else
        {
            pageControl.currentPage = pageControl.currentPage + 1
        }
        var newFrame = scrollView.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl.currentPage)
        scrollView.scrollRectToVisible(newFrame, animated: true)
    }
}


extension IntroViewController : UIScrollViewDelegate
{
    // MARK: UIScrollViewDelegate method implementation
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        var currentPage = floor(scrollView.contentOffset.x / SCREEN_WIDTH);
        // Set the new page index to the page control.
        if Int(currentPage) < 0 {
            currentPage = 0
        }
        pageControl.currentPage = Int(currentPage)
    }
    
    // MARK: page change
    @IBAction func changePage(_ sender: AnyObject) {
        var newFrame = scrollView.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl.currentPage)
        scrollView.scrollRectToVisible(newFrame, animated: true)
    }
    
    
    @IBAction func btnChangeLanguage(_ sender: AnyObject) {
        changeLanguageBottomAlert()
    }
    
    
}


extension IntroViewController {
    
    private func stopAnimation() {
        if animationView != nil {
            animationView?.stop()
            animationViewBg?.removeFromSuperview()
            animationView?.removeFromSuperview()
            animationView = nil
            animationViewBg = nil
        }
    }
    private func startAnimation() {
        
        if animationView == nil {

            animationViewBg = UIView.init()
            animationViewBg?.frame = view.bounds
            animationViewBg?.backgroundColor = UIColor.white
            
            //animationView = AnimationView(name: "7856-tabicon")
            animationView = AnimationView(name: "loaderdata_eye")
            animationView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            animationView?.contentMode = .scaleAspectFit
            animationView?.frame = view.bounds
            animationView?.loopMode = .loop
            animationViewBg?.addSubview(animationView!)
            
            self.view.addSubview(animationViewBg!)
        }
        animationView?.play()
    }
}



extension IntroViewController {
    
    private func registrationMetodEvent (methods: String){
        AppAnalytics.log(.registrationMethod(method: methods))
        TPAnalytics.log(.registrationMethod(method: methods))
    }
    
    private func sendFailedApiRequest (url: String , reason: String){
        AppAnalytics.log(.apiFailure(api: "configuration", reason: reason))
        TPAnalytics.log(.apiFailure(api: "configuration", reason: reason))
    }
    
}


// Handle login process
extension IntroViewController: AlertViewDelegate {
    
    func okButtonAction(tag: Int) {
        if tag == 10 || tag == 11 || tag == 9{
            self.performSegue(withIdentifier: "login", sender: self)
        }
    }
    
    func cancelButtonAction(tag: Int) {
        
        if tag == 9 {
            self.performSegue(withIdentifier: "login", sender: self)
        }
    }
    
    fileprivate func registerUser(registrationMethod : RegistrationMethods)
    {
        if Reachability.isInternetConnected()
        {
                RequestManager.shared.registrationRequest(numberWithCallingCode: self.userMsisdn!, otp: "", registrationMethod: .HE, onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    let response = RegistrationResponse.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        self.processRegistartionResponse(response: response, registrationMethod: registrationMethod)
                    }else{
                        self.stopAnimation()
                        self.showSystemError(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }) { (error) in
                self.stopAnimation()
                print("\(self.TAG) error : \(String(describing: error?.localizedDescription))")
                self.showSystemError(message: NSLocalizedString("M_LOGIN_ERROR", comment: ""))
            }
        }else {
            self.stopAnimation()
            self.showSystemError(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    
    fileprivate func processRegistartionResponse(response : RegistrationResponse, registrationMethod : RegistrationMethods )
    {
        var myProfile = Util.getProfile()
        
        if response.isProfile
        {
            myProfile = response.profile
            myProfile?.registrationMethod = registrationMethod.rawValue
        }else{
            myProfile = Profile.init(json: JSON())
            myProfile?.uniqueId = response.uniqueId
            myProfile?.jabberId = response.jabberId
            myProfile?.password = response.password
            myProfile?.registrationMethod = registrationMethod.rawValue
        }
        
        //  myProfile?.isInterest = true
        myProfile?.isRegister = true
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
        
        UserDefaults.standard.synchronize()
    }
}

extension IntroViewController {
    private func changeLanguageBottomAlert(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // Create your actions - take a look at different style attributes
        let reportAction = UIAlertAction(title: "English(en)", style: .default) { (action) in
            self.selectedLanguage = .english(.us)
            self.updateLanguageAndReload()
        }

        let blockAction = UIAlertAction(title: "Dhivehi(dv)", style: .default) { (action) in
            self.selectedLanguage = .dhivehi
            self.updateLanguageAndReload()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("didPress cancel")
        }

        // Add the actions to your actionSheet
        actionSheet.addAction(reportAction)
        actionSheet.addAction(blockAction)
        actionSheet.addAction(cancelAction)
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
        
        
    }
    
    fileprivate func updateLanguageAndReload()
    {
        // To set localization
        Bundle.set(language: selectedLanguage)
//        APP_DELEGATE.openScreen(screenName: .intro, firstScreen: true)
        self.reloadInputViews()
    }
}





//
//  Util.swift
//  Fyndr
//
//  Created by BlackNGreen on 07/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import CoreTelephony
import SwiftyJSON
import CommonCrypto
import NVActivityIndicatorView
import Kingfisher
import AVFoundation

enum ResoponseStatus : String {
    case SUCCESS = "SUCCESS"
    case FAILED = "FAILED"
}

enum RegistrationMethods : String {
    case OTP = "OTP"
    case HE = "HE"
    case FB = "FB"
    case GOOGLE = "GOOGLE"
    case APPLE = "APPLE"
    case DEFAULT = "DEFAULT"
}

enum SyncStatus : Int {
    case PENDING = 0
    case INPROGRESS = 1
    case SUCCESS = 2
}

enum ProfileType : String {
    case OPERATOR = "OPERATOR"
    case NONOPERATOR = "NONOPERATOR"
}



class Util  {
    
    static let chatDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()
    
    static var timestamp: String {
        return "\(NSDate().timeIntervalSince1970 * 10000)"
    }
    
    static func deviceId() -> String{
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    static func getDeviceName() -> String{
        return UIDevice.current.name
    }
    
    static func getDeviceType() -> String{
        return "IOS"
    }
    
    static func getDeviceInfo() -> String
    {
        let deviceLog =  UIDevice.current.model + " : " + UIDevice.current.systemVersion + " : " + UIDevice.current.name.removeSpecialCharsFromString() + " : " + Reachability.getNetworkType()
        print("DeviceLog : " + deviceLog)
        return deviceLog;
    }
    
    static func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    static func getMncMcc() -> (String,String){
        
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        var mnc = "00"
        var mcc = "00"
        
        if let mobileCC = carrier?.mobileCountryCode {
            mcc = mobileCC
        }
        if let mobileNC = carrier?.mobileNetworkCode {
            mnc = mobileNC
        }
        return(mnc,mcc)
    }

    
    /*
     * 1st get country code from SIM it empty get from device
     */
    static func getCountryIsoCode() ->  String{

//        let networkInfo = CTTelephonyNetworkInfo()
//        let carrier = networkInfo.subscriberCellularProvider
//        let countryCode = carrier?.isoCountryCode
//        if countryCode != nil {
//            return countryCode!
//        }
//        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
//            return countryCode
//        }
        return "MV"
    }
    
    static func isObjectNotNil(object:Any!) -> Bool
    {
        if let _:AnyObject = object as AnyObject?
        {
            return true
        }
        return false
    }
    
    static func appName() -> String
    {
//        if let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String]
//        {
//            return appName as! String
//        }
        return "Fyndr"
    }
    
    static func setLanguage(languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: USER_DEFAULTS.APP_LANGUAGE)
        UserDefaults.standard.synchronize()
    }
    
    
    static func getDeviceDefaultLanguage() -> Language {
        let defaultLngCode = Locale.current.languageCode
        if defaultLngCode == "en" {
            return Language.english(.us)
        }
        return Language.dhivehi
    }
    
    
    
    static func getPhoneLang() -> String
    {
//        if let languageCode = UserDefaults.standard.string(forKey: USER_DEFAULTS.APP_LANGUAGE)
//        {
//            if languageCode == "en" {
//                return "en"
//            }
//        }
//        return "mm"
            return Bundle.getCurrentLanguage().langCodeOnServer
    }

    
    static func getPhoneLangForInternal() -> String
    {
//        if let languageCode = UserDefaults.standard.string(forKey: USER_DEFAULTS.APP_LANGUAGE)
//        {
//            if languageCode == "en" {
//                return "en"
//            }
//        }
//        return "my"
       return Bundle.getCurrentLanguage().code
    }
    
    
    static func isNumberContainsSpecialChar(number : String) -> Bool{
        
        let characterset = CharacterSet(charactersIn: "0123456789")
        if number.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }
        return true
    }
    
    static func isValidNumber(number : String) -> Bool{
        
        var numberToCheck = number.unformattedPhoneNumber()
        numberToCheck = numberToCheck.removePlus()
        if numberToCheck.count >= MSISDN_MINIMUM_LENGTH &&  numberToCheck.count <= MSISDN_MAXIMUM_LENGTH {
            return numberToCheck.isNumber
        }
        return false
    }
    
    static func getDirectoryPath() -> String{
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            let imagesDirectoryPath = documentDirectoryPath.appending("/Fyndr")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: imagesDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: imagesDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                    print(imagesDirectoryPath)
                } catch {
                    print("Error creating images folder in documents dir: \(error)")
                }
            }
            
            return imagesDirectoryPath;
        }
        return ""
    }
    
    static func deleteProfilePic(){
        
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard paths.first != nil else {
            return
        }
        let filePath = Util.getDirectoryPath()+"/image.jpeg"
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    
    class func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }
    
    class func sha256String1(data : Data) -> String? {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        // return Data(bytes: hash)
        return String.init(data: Data(bytes: hash), encoding: String.Encoding.utf8)
    }
    
    
    class func sha256String(data : Data) -> String? {
        return Util.hexStringFromData(input: Util.digest(input: data as NSData))
    }
    
    
    class func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    class  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
    
    static func getCountryList() -> [Country]? {
        
        if let countryJsonPath = Bundle.main.path(forResource: "countries", ofType: "json")
        {
            let url = URL.init(fileURLWithPath: countryJsonPath)
            do{
                let countryJsonData = try Data.init(contentsOf: url)
                let countryListJsonObj = try JSON.init(data: countryJsonData)
                
                if let countryListJson = countryListJsonObj.array {
                    
                    var countries = [Country]()
                    for countryJson : JSON in countryListJson
                    {
                        let country = Country.init(json: countryJson)
                        countries.append(country)
                    }
                    return countries
                }
                
            }catch let error {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    class func setDefaultCountryCode(){
        if let defaultCountyCode = self.getDefaultCountyCode()
        {
            Util.setUserCountryCode(countryCode: defaultCountyCode)
        }
    }
    
    class func getDefaultCountyCode() -> String? {
        
        let countryIsoCode = Util.getCountryIsoCode()
        let countryList = Util.getCountryList()
        
        if let filteredList = countryList?.filter( { return $0.code == countryIsoCode.uppercased() })
        {
            return filteredList.first?.dialCode
        }
        return nil
    }
    
    
    static func isStringNotEmpty(string:String?) -> Bool
    {
        if(Util.isObjectNotNil(object: string)){
            
            let trimmedString = string?.trimmingCharacters(in: .whitespaces)
            return trimmedString?.count ?? 0 > 0
        }
        return false
    }
    
    static func defaultThumImage() -> UIImage?
    {
        return UIImage(named: "create_profile_thumb")
    }
    
    static func defaultBioThumImage() -> UIImage?
    {
        return UIImage(named: "user-defaultBio")
    }
    
    static func defaultInterestImage() -> UIImage?
    {
        return UIImage(named: "bookmark-icon")
    }
    
    
    static func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}


extension Util
{
    static func getProfile() -> Profile?
    {
        let myProfile = UserDefaults.standard.retrieve(object: Profile.self, fromKey: USER_DEFAULTS.MY_PROFILE)
        return myProfile
    }
    
    static func saveProfile(myProfile : Profile?)
    {
        if let myProfile = myProfile {
            UserDefaults.standard.save(customObject: myProfile, inKey: USER_DEFAULTS.MY_PROFILE)
            UserDefaults.standard.synchronize()
        }
        //        else{
        //            UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.MY_PROFILE)
        //        }
    }
    
    static func getChatConfiguration() -> ChatConfiguration?
    {
        let chatConfiguration = UserDefaults.standard.retrieve(object: ChatConfiguration.self, fromKey: USER_DEFAULTS.CHAT_CONFIG)
        return chatConfiguration
    }
    
    static func setChatConfiguration(chatConfiguration : ChatConfiguration?)
    {
        if let chatConfiguration = chatConfiguration {
            UserDefaults.standard.save(customObject: chatConfiguration, inKey: USER_DEFAULTS.CHAT_CONFIG)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func getSipConfiguration() -> SipConfiguration?
    {
        let chatConfiguration = UserDefaults.standard.retrieve(object: SipConfiguration.self, fromKey: USER_DEFAULTS.SIP_CONFIG)
        return chatConfiguration
    }
    
    static func setSipConfiguration(sipConfiguration : SipConfiguration?)
    {
        if let sipConfiguration = sipConfiguration {
            UserDefaults.standard.save(customObject: sipConfiguration, inKey: USER_DEFAULTS.SIP_CONFIG)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    static func getReportReasons() -> [Reason]?
    {
        if let reportReasons = UserDefaults.standard.retrieve(object: ReportReasons.self, fromKey: USER_DEFAULTS.REPORT_REASONS)
        {
            return reportReasons.reasons
        }
        return nil
    }
    
    static func saveReportReasons(reportReasons : ReportReasons?)
    {
        if let reportReasons = reportReasons {
            UserDefaults.standard.save(customObject: reportReasons, inKey: USER_DEFAULTS.REPORT_REASONS)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    static func clearDatabase()
    {
        DatabaseManager.shared.deleteAllChats()
    }
    
    
    static func getCurrentScreen() -> (ScreenName, Bool)
    {
        if let profile = getProfile()
        {
            if profile.isProfile && profile.isInterest
            {
                return (.dashboard, true)
            }else if profile.isProfile
            {
                return (.interest, false)
            }else if profile.isRegister {
                return (.cretaeProfile, false)
            }else {
                return (.registartion, false)
            }
        }
        return (.intro, false)
    }
    
    static func getAppConfig() -> AppConfiguration?
    {
        let myProfile = UserDefaults.standard.retrieve(object: AppConfiguration.self, fromKey: USER_DEFAULTS.APP_CONFIG)
        return myProfile
    }
    
    static func saveAppConfig(configuration : AppConfiguration)
    {
        UserDefaults.standard.save(customObject: configuration, inKey: USER_DEFAULTS.APP_CONFIG)
    }
    
    static func getInterestList() -> InterestList?
    {
        let interestList = UserDefaults.standard.retrieve(object: InterestList.self, fromKey: USER_DEFAULTS.INTEREST_LIST)
        return interestList
    }
    
    static func saveInterestList(interestList : InterestList)
    {
        UserDefaults.standard.save(customObject: interestList, inKey: USER_DEFAULTS.INTEREST_LIST)
    }
    
    //MARK: - Country code
    class func getUserCountryCode() -> String {
        
        let countryCode = UserDefaults.standard.object(forKey: USER_DEFAULTS.COUNTRY_CODE)
        if let countryCode = countryCode as? String
        {
            return countryCode
        }
        else{
            return "96"
        }
    }
    
    class func setUserCountryCode(countryCode : String) {
        UserDefaults.standard.set(countryCode, forKey: USER_DEFAULTS.COUNTRY_CODE)
        UserDefaults.standard.synchronize()
    }
    
    class func getMsisdn() -> String {
        
        let countryCode = UserDefaults.standard.object(forKey: USER_DEFAULTS.MSISDN_CODE)
        if let countryCode = countryCode as? String
        {
            return countryCode
        }
        else{
            return ""
        }
    }
    
    
    class func setMsisdn(msisdn : String) {
        UserDefaults.standard.set(setMsisdn, forKey: USER_DEFAULTS.MSISDN_CODE)
        UserDefaults.standard.synchronize()
    }
    
    class func getUrlLastString(url: String) -> String {
    
        let spliteArray = url.components(separatedBy: "/")
        let lastString = spliteArray.last
        
        return lastString ?? ""
    }
    
    static func getChatHistory(uniqId: String) -> ChatHistory{
        var chatHistory = ChatHistory()
        chatHistory = DatabaseManager.shared.getChatHistory(for: uniqId)!
        return chatHistory
        
    }
    
    static func getIsValidityIsAvalibale(userUdid: String) -> Bool{
        let checkValidityModelResponse = CheckSubscriptionResponse.init();
        if let checkValidity = checkValidityModelResponse.getCheckSubData() {
            if let checkSubModel = checkValidity.subscription {
                if checkSubModel.statusStatus == true {
                    if let currentSerTime = checkSubModel.currentTime , let validityTime = checkSubModel.validity {
                        if Int64(currentSerTime) >= getCurrentMillis() {
                            if currentSerTime <= validityTime {
                                return true
                            }else {
                                return false
                            }
                        }else {
                            if getCurrentMillis() <= Int64(validityTime) {
                                return true
                            }else {
                                return false
                            }
                        }
                    }else{
                       return getChatAllowedForThisUser(userId: userUdid)
                    }
                }else{
                   return getChatAllowedForThisUser(userId: userUdid)
                }
            }else{
               return getChatAllowedForThisUser(userId: userUdid)
            }
        }else{
            return getChatAllowedForThisUser(userId: userUdid)
        }
    }
    
    static func getCurrentMillis()->Int64{
        return  Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    
    
    static func getSubscribeValidityIsAvalibale() -> Bool{
        let checkValidityModelResponse = CheckSubscriptionResponse.init();
        if let checkValidity = checkValidityModelResponse.getCheckSubData() {
            if let checkSubModel = checkValidity.subscription {
                if checkSubModel.statusStatus == true {
                    if let currentSerTime = checkSubModel.currentTime , let validityTime = checkSubModel.validity{
                        if Int64(currentSerTime) >= getCurrentMillis() {
                            if currentSerTime <= validityTime {
                                return true
                            }else {
                                return false
                            }
                        }else {
                            if getCurrentMillis() <= Int64(validityTime) {
                                return true
                            }else {
                                return false
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    
    
    static func getChatAllowedForThisUser(userId: String) -> Bool{
        if let appPolicy = getAppConfig()?.subEvents {
            for appPolicyObj: ConfigSubEventModel in appPolicy {
                if appPolicyObj.event == "chat" {
                    if let polictString: String = appPolicyObj.policy {
                        let policyArrays = polictString.components(separatedBy: "_")
                        let userCounts = Int(policyArrays.first ?? "0") ?? 0
                        let nomberOfChats = Int(policyArrays[1]) ?? 0
                        let totalChatUserCount = DatabaseManager.shared.getChatUserCounts()
                        let userChatCount = DatabaseManager.shared.getUserChatCount(userId: userId)
                        if userCounts > 0  && userCounts >= totalChatUserCount {
                            if nomberOfChats > 0 && nomberOfChats >= userChatCount{
                                DatabaseManager.shared.insertAndUpdateAppPolicyData(userId: userId, chatCount: userChatCount + 1)
                                return true
                            }
                        }
                    }
                }
            }
        }else {
            return true
        }
        return false
    }
    
    
    static func hexStringToUIColor (hexColor: String, opicity: Float) -> UIColor {
        var cString:String = hexColor.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(opicity)
        )
    }
    
}



extension Util
{
    class func showLoader()
    {
        let activityData = ActivityData.init(size: CGSize(width: SCREEN_WIDTH*0.2 , height: SCREEN_WIDTH*0.2) , message: "", messageFont: nil, messageSpacing: nil, type: NVActivityIndicatorType.ballClipRotatePulse, color: UIColor.white, padding:CGFloat(10) , displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor.init(red: 0, green: 0, blue: 0, alpha:0.5), textColor: nil)
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    }
    
    class func hideLoader()
    {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        }
    }
    class func isAnimating() -> Bool
    {
        return NVActivityIndicatorPresenter.sharedInstance.isAnimating
    }
    
    
    
    
    
    
}

extension String {
    func characterAtIndex(index: Int) -> Character? {
        var cur = 0
        for char in self {
            if cur == index {
                return char
            }
            cur = +1
        }
        return nil
    }
}


//
//  Constants.swift
//  Fyndr
//
//  Created by BlackNGreen on 25/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

let FB_KIT_LOGIN = false // Enable Account kit login
let TESTING_MODE = false //Enable OTP flow if FB_KIT_LOGIN false

let AWS_IP = true // true : Use AWS IP, false : use PUBLIC_IP value
let PUBLIC_IP = false// if AWS_IP false. true : use 111 server public IP, false : use 111 local IP,

let DOMAIN_NAME = "mdv.fyndrapp.com"

let PRIVACY_URL = "http:/mdv.fyndrapp.com/privacyPolicy.php"
let TERM_OF_SERICE_URL = "http://mdv.fyndrapp.com/termsofuse.php"
let TERM_OC_CONDITIONS_URL = "http://mdv.fyndrapp.com/termsandcondition.php"
let FEEDBCK_URL = "http://mdv.fyndrapp.com/feedback/index.php"
let FAQ_URL = "http://mdv.fyndrapp.com/faq.php"

let USE_CUSTOM_FONT = false
let SCREEN_BOUND = UIScreen.main.bounds

let SCREEN_SIZE = UIScreen.main.bounds.size
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT_80 = UIScreen.main.bounds.size.height*0.8
let SCREEN_WIDTH_80 = UIScreen.main.bounds.size.width*0.8

var headerMinHeight: CGFloat = 64 + UIApplication.shared.statusBarFrame.height + UIScreen.main.bounds.size.height*0.1

let MSISDN_MINIMUM_LENGTH = 6
let MSISDN_MAXIMUM_LENGTH = 15
let OTP_LENGTH = 6

let MIN_AGE = -15

let defaultGradientColors : [UIColor] = [.defaultGradientStartColor, .defaultGradientEndColor]
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
let SEARCH_TYPE_DEFAULT = "DEFAULT"


let timeoutIntervalForRequest = 20

 let DEFAULT_COUNTY_CODE = "IN"
 let DEFAULT_COUNTY_CALLING_CODE = "+91"
 let DEFAULT_COUNTY_NAME = "India"



struct USER_DEFAULTS {
    static let AUTH_TOKEN = "Authorization_Bearer"
    static let BASE_URL = "BASE_URL"
    static let MY_PROFILE = "MY_PROFILE"
    
    static let USER_ID = "USER_ID"
    static let APP_CONFIG = "APP_CONFIG"
    static let APP_HE_DATA = "heData"
    static let INTEREST_LIST = "INTEREST_LIST"    
    static let USER_INFO = "USER_INFO"
    static let COUNTRY_CODE = "COUNTRY_CODE"
    static let CITY_LIST = "CITY_LIST"
    
    static let BROWSE_PROFILE_LIST = "BROWSE_PROFILE_LIST"
    static let BROWSE_CATEGORY_LIST = "BROWSE_CATEGORY_LIST"

    static let CHAT_CONFIG = "CHAT_CONFIG"
    static let SIP_CONFIG = "SIP_CONFIG"

    static let TEMP_IMG_URL = "TEMP_IMG_URL"
    static let REPORT_REASONS = "REPORT_REASONS"
    
    static let GET_BOOKMARK = "GET_BOOKMARK"
    static let GET_BLOCKLIST = "GET_BLOCKLIST"
    static let GET_CHAT_HISTORY = "GET_CHAT_HISTORY"
    
    static let RECENT_SUCCESS = "RECENT_CHAT"
    static let CONNECTIONS_SUCCESS = "CHAT_CONNECTIONS"
    static let APP_VERSION_INFO = "APP_VERSION_INFO"
    static let APP_SUB = "APP_SUB"
    static let APP_LANGUAGE = "APP_LANGUAGE"
    static let PEDING_PACK = "PEDING_PACK_ID"
    static let PEDING_ORDER_ID = "PEDING_ORDER_ID"
    static let USER_TYPE = "USER_TYPE"

    
    static let MSISDN_CODE = "USER_MSISDN"


    


}

let AppAnalytics =  AnalyticsManager.init(engine: AppAnalyticsEngine())
let TPAnalytics =  AnalyticsManager.init(engine: ThirdPartyAnalytics())

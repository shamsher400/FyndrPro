//
//  AnalyticsEvent.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

enum Screen : String {
    case intro = "intro"
    case register = "register"
    case otpScreen = "otp"
    case createProfile = "create_p"
    case interest = "interest"
    case browseProfile = "browse_p"
    case userProfileDetails = "p_details"
    case myProfile = "my_profile"
    case updateProfile = "update_p"
    case setting = "setting"
    case block = "block"
    case help = "help"
    case faq = "faq"
    case bookmark = "bookmark"
    case recent = "recent"
    case chat = "chat"
    case report = "report"
    case cityList = "city"
    case recordVideo = "v_record"
    case playView = "preview_v"
    case subscribe = "subscribe"
    case wifi_setting = "wifi_setting"
    case subscribe_alert = "subscribe_alert"
    case language = "c_lang"
    case social = "social_reg"

}


enum EventName : String {
    
    case screen
    case start
    case background
    case foreground
    case terminate
    case filter
    case profile
    case bookmark
    case block
    case call
    case video
    case view_image
    case api_fail
    case report_p
    case discard
    case reg_method
    case otp_req
    case resend_otp
    case failed_otp
    case image
    case image_error
    case record_v
    case x_con
    case chat_open
    case visibility
    case dnd
    case pack_sel
    case subscription
}


enum AnalyticsEvent  {
    
    case start
    case enterBackground
    case enterForeground
    case terminate
    case openScreen(screen: Screen)
    case browseFilter(categoryId: String)
    case profileOpen(uniqueid: String, action: String)
    case bookmark(uniqueid: String, action: String)
    case block(uniqueid: String, action: String)
    case callAttempted(uniqueid: String)
    case callAttemptedWithCid(cid: String, uniqueid: String)
    case playPauseVideo(uniqueid: String, videoId: String, action: String)
    case imageView(uniqueId : String, imageId: String)
    case apiFailure(api : String, reason: String)
    case reportPorfile(uniqueid: String, reasonId: String)
    case discard(uniqueid: String)
    case registrationMethod(method: String)
    case otpRequest(msisdn: String, countryCode: String)
    case resendOtp
    case otpFailed(msisdn: String, reason: String)
    case image(action: String)
    case recordVideo(action: String)
    case xmppStatus(status: String)
    case chatOpen(uid: String, xmppStatus: String)
    case visibility(action: String)
    case dnd(action: String)
    case packSelection(packId: String)
    case subscription(packId: String, status: String)

}


extension AnalyticsEvent {
    
    var name : String {
        switch self {
        case .openScreen:
            return EventName.screen.rawValue
        case .start:
            return EventName.start.rawValue
        case .enterBackground:
            return EventName.background.rawValue
        case .enterForeground:
            return EventName.foreground.rawValue
        case .terminate:
            return EventName.terminate.rawValue
        case .browseFilter:
            return EventName.filter.rawValue
        case .profileOpen:
            return EventName.profile.rawValue
        case .bookmark:
            return EventName.bookmark.rawValue
        case .callAttempted:
            return EventName.call.rawValue
        case .callAttemptedWithCid:
            return EventName.call.rawValue
        case .playPauseVideo:
            return EventName.video.rawValue
        case .imageView:
            return EventName.view_image.rawValue
        case .block:
            return EventName.block.rawValue
        case .discard:
            return EventName.discard.rawValue
        case .reportPorfile:
            return EventName.report_p.rawValue
        case .apiFailure:
            return EventName.api_fail.rawValue
        case .registrationMethod:
            return EventName.reg_method.rawValue
        case .otpRequest:
            return EventName.otp_req.rawValue
        case .resendOtp:
            return EventName.resend_otp.rawValue
        case .otpFailed:
            return EventName.failed_otp.rawValue
        case .image:
            return EventName.image.rawValue
        case .recordVideo:
            return EventName.record_v.rawValue
        case .xmppStatus:
            return EventName.x_con.rawValue
        case .chatOpen:
            return EventName.chat_open.rawValue
        case .visibility:
            return EventName.visibility.rawValue
        case .dnd:
            return EventName.dnd.rawValue
        case .packSelection:
            return EventName.pack_sel.rawValue
        case .subscription:
            return EventName.subscription.rawValue
            

        }
    }
}


extension AnalyticsEvent {
    
    var parameter : [String : Any]
    {
        switch self {
        case .openScreen(let screen):
            return ["name" : screen.rawValue , "ts": Date().millisecondsSince1970]
        case .browseFilter(let categoryId):
            return ["categoryId" : categoryId , "ts": Date().millisecondsSince1970]
        case .profileOpen(let uniqueid, let action):
            return ["uid" : uniqueid,"action": action , "ts": Date().millisecondsSince1970]
            
        case .bookmark(let uniqueid, let action):
            return ["uid" : uniqueid, "ts": Date().millisecondsSince1970, "action" : action]
            
        case .block(let uniqueid, let action):
            return ["uid" : uniqueid , "ts": Date().millisecondsSince1970, "action" : action]
            
        case .callAttempted(let uniqueid):
            return ["uid" : uniqueid , "ts": Date().millisecondsSince1970]
            
        case .callAttemptedWithCid( let cid, let uniqueid):
            return ["cid": cid, "uid" : uniqueid , "ts": Date().millisecondsSince1970]
        case .playPauseVideo(let uniqueid, let videoId, let action):
            return ["uid" : uniqueid ,"videoid": videoId ,"action": action, "ts": Date().millisecondsSince1970]
            
        case .imageView(let uniqueid, let imageId):
            return ["uid" : uniqueid , "imageId" : imageId , "ts": Date().millisecondsSince1970]
        case .start:
            return ["ts": Date().millisecondsSince1970]
            
        case .enterBackground:
            return ["ts": Date().millisecondsSince1970]
            
        case .enterForeground:
            return ["ts": Date().millisecondsSince1970]
            
        case .terminate:
            return ["ts": Date().millisecondsSince1970]
        case .apiFailure(let api, let error):
            return ["api" : api,"error" : error , "ts": Date().millisecondsSince1970]
            
        case .reportPorfile(let uniqueid, let reasonId):
            return ["uid" : uniqueid, "reason" : reasonId , "ts": Date().millisecondsSince1970]
            
        case .discard(let uniqueid):
            return ["uid" : uniqueid , "ts": Date().millisecondsSince1970]
            
        case .registrationMethod(let method):
            return ["name" : method , "ts": Date().millisecondsSince1970, "mcc_mnc" : "\(Util.getMncMcc().1)_\(Util.getMncMcc().0)" , "device_info" : Util.getDeviceInfo()]
            
        case .otpRequest(let msisdn,let countryCode):
            return ["msisdn" : msisdn, "cc": countryCode , "ts": Date().millisecondsSince1970]
            
        case .resendOtp:
            return ["ts": Date().millisecondsSince1970]
            
        case .otpFailed(let msisdn,let reason):
            return ["msisdn" : msisdn, "reason": reason, "ts": Date().millisecondsSince1970]
            
        case .image(let action):
            return ["action" : action, "ts": Date().millisecondsSince1970]

        case .recordVideo(let action):
            return ["action" : action, "ts": Date().millisecondsSince1970]
        case .xmppStatus(let status):
            return ["status" : status, "ts": Date().millisecondsSince1970]
        case .chatOpen(let uid,let xmppStatus):
            return ["uid": uid,"status" : xmppStatus, "ts": Date().millisecondsSince1970]
        case .visibility(let action):
            return ["action" : action, "ts": Date().millisecondsSince1970]
        case .dnd(let action):
            return ["action" : action, "ts": Date().millisecondsSince1970]
        case .packSelection( let packId):
            return ["packId": packId, "ts": Date().millisecondsSince1970]
        case .subscription(let packId,let status):
            return ["packId" : packId, "status": status, "ts": Date().millisecondsSince1970]


        }
    }
}

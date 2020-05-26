//
//  RequestManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestManager {
    
    typealias success = (_ responseJSON: JSON) -> Void
    typealias failure = (_ error: Error?) -> Void
    typealias progress = (_ progress: Progress?) -> Void
    
    static let shared = RequestManager()
    private init() {}
    

    func downloadRequest(url : String,destinationUrl : String, onCompletion success: @escaping success, onFailure failure: @escaping failure, onProgress progress : @escaping progress)
    {

        AFWrapper().downloadRequest(url,destinationUrl:destinationUrl, param: nil, headers: Request.requestHeaderParameter()) { (responseJson, error, progressUpdate) in
            if let response = responseJson {
                success(response)
            } else if let progressUpdate = progressUpdate{
                progress(progressUpdate)
            }else{
                failure(error)
                self.sendFailedApiRequest(url: url, reason: String(describing: error?.localizedDescription))
            }
        }
    }
    
    
    func appConfigurationRequest(configurationType : ConfigurationType, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ConfigurationRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: ConfigurationRequest.requestParameter(configurationType : configurationType), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
                failure(error)
            }
        }
    }
    
    
    func appConfigurationChangeLanguageRequest(configurationType : ConfigurationType, languageCode: String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ConfigurationRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: ConfigurationRequest.requestParameter(configurationType : configurationType, languageCode: languageCode), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
                failure(error)
            }
        }
    }
    
    func checkHE(urlString: String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        AFWrapper().postRequest(urlString, param: HERequest.requestParameter(), headers: HERequest.requestParameter(), completionHandler: { ( responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
            }
        })
    }
    
    func checkSubscription(unique: String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = CheckSubscriptionRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: CheckSubscriptionRequest.requestParameter(uniqueId: unique), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
            }
        }
    }
    
    func checkSubscriptionWithOrderId(unique: String, orderId: String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = CheckSubscriptionRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: CheckSubscriptionRequest.requestParameter(uniqueId: unique, orderId: orderId), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
            }
        }
    }
    
    
    func sendOtpRequest(numberWithCallingCode : String,callingCode : String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = SendOtpRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: SendOtpRequest.requestParameter(number: numberWithCallingCode, callingCode: callingCode), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
            }
        }
    }
    
    
    func registrationRequest(numberWithCallingCode : String, otp : String, registrationMethod : RegistrationMethods, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = RegistrationRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: RegistrationRequest.requestParameter(number : numberWithCallingCode,otp : otp, registrationMethod : registrationMethod), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
                failure(error)
            }
        }
    }
    
    
    func socialRegistrationRequest(registrationMethod : RegistrationMethods, socialProfile: SocialProfileModel, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = RegistrationRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: RegistrationRequest.requestParameter(registrationMethod : registrationMethod, socialProfile: socialProfile), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
                failure(error)
            }
        }
    }
    
    
    func createUpdateProfileRequest(profile : Profile, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = CreateProfileRequest.URLParams.APIPath
        AFWrapper().postRequest(urlString, param: CreateProfileRequest.requestParameter(profile: profile), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
                self.sendFailedApiRequest(url: urlString, reason: String(describing: error?.localizedDescription))
            }
        }
    }
    
    func updateInterestRequest(interestList : [String], onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = InterestRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: InterestRequest.requestParameter(interestList: interestList), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    func getPacksFromServer( onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = GetPacksRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: GetPacksRequest.requestParameter(), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    
    func notifyServerForPurchase(receipt: String,paymentRequest :InAppPaymentRequest, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = PurchaseNotifyRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: PurchaseNotifyRequest.requestParameter(receipt: receipt,paymentRequest :paymentRequest), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    func purchaseOperatorPscks(packId: String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = OperatorPackPurchaseRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: OperatorPackPurchaseRequest.requestParameter(packId: packId), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    func unsubscribePack(onCompletion success: @escaping success, onFailure failure: @escaping failure) {
        let urlString = UnsubscribePackRequst.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: UnsubscribePackRequst.requestParameter(), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    func resentPurchaseOtp(orderId: String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = SubscribeResentOtpRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: SubscribeResentOtpRequest.requestParameter(orderId: orderId), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func purchasePackWithOtp(orderId: String, otp: String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = PurchasePackWithOtpRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: PurchasePackWithOtpRequest.requestParameter(orderId: orderId, otp: otp), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    
    func browseRequest(searchType : String,isFirst : Bool, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = BrowseRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: BrowseRequest.requestParameter(searchType: searchType, isFirst : isFirst), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                self.sendFailedApiRequest(url: urlString, reason: error?.localizedDescription ?? "")
                failure(error)
            }
        }
    }
    
    func cancelBrosweRequest()
    {
        let urlString = BrowseRequest.URLParams.APIPath
        AFWrapper().cancelRequestWithUrl(url: urlString)
    }
    
    func cancelRequestWithUrl(url : String){
        AFWrapper().cancelRequestWithUrl(url: url)
    }

    func getBookmarksRequest(pageIndex : Int, pageSize : Int, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = BookmarkRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: BookmarkRequest.requestParameter(bookmarkIds: nil, action: BookmarkAction.GET, pageIndex: pageIndex, pageSize: pageSize) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func addBookmarkRequest(bookmarkIds : [BookmarkIds], onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = BookmarkRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: BookmarkRequest.requestParameter(bookmarkIds: bookmarkIds, action: BookmarkAction.ADD, pageIndex: 0, pageSize: 0) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func deleteBookmarkRequest(bookmarkIds : [BookmarkIds], onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = BookmarkRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: BookmarkRequest.requestParameter(bookmarkIds: bookmarkIds, action: BookmarkAction.DELETE, pageIndex: 0, pageSize: 0) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    func getBlockListRequest(pageIndex : Int, pageSize : Int, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = BlackListRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: BlackListRequest.requestParameter(blockListIds: nil, action: BlackListAction.GET, pageIndex: pageIndex, pageSize: pageSize) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func addBlockListRequest(blockListIds : [BlockIds], onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = BlackListRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: BlackListRequest.requestParameter(blockListIds: blockListIds, action: BlackListAction.ADD, pageIndex: 0, pageSize: 0) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func deleteBlockListRequest(blockListIds : [BlockIds], onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = BlackListRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: BlackListRequest.requestParameter(blockListIds: blockListIds, action: BlackListAction.DELETE, pageIndex: 0, pageSize: 0) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func createResourceRequest(type : ResourceType, name : String, size : Int, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ResourceRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: ResourceRequest.requestParameter(type: type, name: name, size: size) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)

                var reason = ""
                if let errorReason = error?.localizedDescription
                {
                    reason = errorReason
                }
                self.sendFailedApiRequest(url: urlString, reason: reason)
            }
        }
    }
    
    func uploadResourceRequest(data : Data, fileName : String, resourceUrl : String,onCompletion success: @escaping success, onFailure failure: @escaping failure, onProgress progress : @escaping progress)
    {
        guard let hash = Util.sha256String(data: data)  else {
            failure(AppError.invalidHash)
            return
        }
        
        AFWrapper().uploadRequest(data: data, fileName: fileName, resourceUrl: resourceUrl, param: ResourceRequest.uploadResourceRequestParameter(password: hash), headers: Request.requestHeaderParameter()){ (responseJson, error, progressUpdate) in
            
            if let response = responseJson {
                success(response)
            } else if let progressUpdate = progressUpdate{
                progress(progressUpdate)
            }else{
                failure(error)
            }
        }
    }
    
    func deleteImageRequest(url : String,onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        AFWrapper().deleteRequest(url, param: ResourceRequest.deleteImageRequestParameter(), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func getImageRequest(url : String,onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        AFWrapper().getRequest(url, param: ResourceRequest.getImageRequestParameter(), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    func deleteVideoRequest(uid : String, vedioId: String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let url = ResourceRequest.URLParams.APIPath + "/" + uid + "/" + vedioId

        AFWrapper().deleteVideoGetRequest(url, param: ResourceRequest.deleteVideoRequestParameter(), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    
    func reportProfileResoneRequest(onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ReportRequest.URLParams.APIPathGetReasons
        
        AFWrapper().postRequest(urlString, param: ReportRequest.requestParameterReportReasons(), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func reportProfileRequest(reportedId : String, reasonId : String, reason : String, comments : String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ReportRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: ReportRequest.requestParameter(reportedId : reportedId, reasonId : reasonId, reason: reason, comments :comments) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func settingRequest(isMute : Bool, isVisible : Bool, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = SettingRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: SettingRequest.requestParameter(isMute: isMute, isVisible: isVisible) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func addConnectionRequest(bParty : String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ConnectionRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: ConnectionRequest.requestParameter(bParty: bParty, operation: ConnectionOperation.add) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func getRecentConnectionRequest(bParty : String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ConnectionRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: ConnectionRequest.requestParameter(bParty: bParty, operation: ConnectionOperation.getRecentList, pageNumber: 0, pageSize: 500) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func getConnectionRequest(bParty : String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ConnectionRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: ConnectionRequest.requestParameter(bParty: bParty, operation: ConnectionOperation.getConnectionList, pageNumber: 0, pageSize: 500) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func registerPushTokenRequest(token : String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = PushRegistartionRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: PushRegistartionRequest.requestParameter(token: token) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func getProfileRequest(uniqueId : String, onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = ProfileDetailRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: ProfileDetailRequest.requestParameter(uniqueId: uniqueId) , headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func deleteAccountRequest(onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = DeleteAccountRequest.URLParams.APIPath

        AFWrapper().postRequest(urlString, param: DeleteAccountRequest.requestParameter(), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
    
    func isRequestInProgress(url : String) -> Bool
    {
       return AFWrapper().isRequestInProgress(url: url)
    }
    
    func logEventRequest(events : [Event], onCompletion success: @escaping success, onFailure failure: @escaping failure)
    {
        let urlString = EventLogRequest.URLParams.APIPath
        
        AFWrapper().postRequest(urlString, param: EventLogRequest.requestParameter(events: events), headers: Request.requestHeaderParameter()) { (responseJson, error) in
            if let response = responseJson {
                success(response)
            }else{
                failure(error)
            }
        }
    }
}

extension RequestManager {
    private func sendFailedApiRequest (url: String , reason: String){
        let urlArray = url.components(separatedBy: "/")
        if let urlKey = urlArray.last {
            AppAnalytics.log(.apiFailure(api: urlKey, reason: reason))
            TPAnalytics.log(.apiFailure(api: urlKey, reason: reason))
        }
    }
}

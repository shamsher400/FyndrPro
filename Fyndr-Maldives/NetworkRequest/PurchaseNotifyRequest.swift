//
//  PurchaseNotifyRequest.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 04/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct PurchaseNotifyRequest {
    
//    curl -X POST -d '{"orderId":"sdfkjh","appleOrderId":"sdkjh","status":true,"receiptData":"sekjhskdj","uniqueId":"sdc","deviceId":"sd","requestSource":"APP","language":"mm"}' https://mobitellka.fyndrapp.com:8088/profileManager/postlogin/completeappletransaction
    
    struct URLParams {
        static let APIPath = Request.RequestURL.baseUrl + "profileManagerMaldives/postlogin/completeappletransaction"
    }
    
    struct APIKeys {
        
        static let requestSource = "requestSource"
        static let uniqueId = "uniqueId"
        static let interestList = "interestList"
        static let deviceId = "deviceId"
        static let language = "language"
        static let receipt = "receiptData"
        static let orderId = "orderId"
        static let appleOrderId = "appleOrderId"

        static let status = "status"

        
    }
    
    struct APIValue {
        static let requestSource = "APP"
        static let isDelta = false
        static let status = true
    }
    
    static func requestParameter(receipt: String, paymentRequest :InAppPaymentRequest) -> [String: Any]
    {
        var param = [String: Any]()
        param[APIKeys.requestSource] = APIValue.requestSource
        if let userId = UserDefaults.standard.object(forKey: USER_DEFAULTS.USER_ID)
        {
            param[APIKeys.uniqueId] = userId
        }
        param[APIKeys.deviceId] = Util.deviceId()
        param[APIKeys.language] = Util.getPhoneLang()
        param[APIKeys.receipt] = receipt
        param[APIKeys.orderId] = paymentRequest.txnid
        param[APIKeys.status] = APIValue.status
        param[APIKeys.appleOrderId] = paymentRequest.transactionId
        return param
    }
}

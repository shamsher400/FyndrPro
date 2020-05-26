//
//  InAppSharedPrefrance.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 03/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class InAppSharedPrefrance: NSObject {
    
    let transactionStatus = "transactionStatus"
    
    func setTransactionStatusPending() {
        print("setTransactionStatusPending")
        
        UserDefaults.standard.set(true, forKey: transactionStatus)
        UserDefaults.standard.synchronize()
    }
    
    func getTransactionStatus() -> Bool {
        print("getTransactionStatus")
        return UserDefaults.standard.bool(forKey: transactionStatus) ? true : false
    }
    
    func clearTransactionStatus() {
        
        print("clearTransactionStatus")
        
        UserDefaults.standard.set(false, forKey: transactionStatus)
        
        removeObjectForKey(key: "key_trans_id")
        removeObjectForKey(key: "key_payment_status")
        removeObjectForKey(key: "key_message")
        removeObjectForKey(key: "key_pack_name")
        removeObjectForKey(key: "key_pack_id")
        removeObjectForKey(key: "key_inapp_id")
        removeObjectForKey(key: "key_receipt")
        removeObjectForKey(key: "key_payment_type")
        
        UserDefaults.standard.synchronize()
    }
    
    func saveTransactionInfo(pack : PacksModel, transId : String? ,paymentStatus : String?, message : String?, paymentRequest :InAppPaymentRequest) {
        
        print("saveTransactionInfo for transId =  \(String(describing: transId))")
        
        if let transIdValue = transId {
            UserDefaults.standard.set(transIdValue, forKey: "key_trans_id")
        }
        if let paymentStatusValue = paymentStatus{
            UserDefaults.standard.set(paymentStatusValue, forKey: "key_payment_status")
        }
        if let messageStr = message{
            UserDefaults.standard.set(messageStr, forKey: "key_message")
        }
        
        if let packName = pack.packName{
            UserDefaults.standard.set(packName, forKey: "key_pack_name")
        }else{
            removeObjectForKey(key: "key_pack_name")
        }
        
        if let packId = pack.packId {
            UserDefaults.standard.set(packId, forKey: "key_pack_id")
        }else{
            removeObjectForKey(key: "key_pack_id")
        }
        
        if let inappProductId =  pack.productId
        {
            UserDefaults.standard.set(inappProductId, forKey: "productId")
        }else{
            removeObjectForKey(key: "productId")
        }
        
        UserDefaults.standard.set(paymentRequest.receipt, forKey: "key_receipt")
        UserDefaults.standard.set(paymentRequest.txnStatus, forKey: "key_txn_status")
        UserDefaults.standard.set(paymentRequest.paymentType, forKey: "key_payment_type")
        UserDefaults.standard.set(paymentRequest.transactionId, forKey: "key_transaction_id")
        UserDefaults.standard.set(paymentRequest.paymentType, forKey: "key_payment_type")
        
        if let txnid = paymentRequest.txnid {
            UserDefaults.standard.set(txnid, forKey: "key_txn_id")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    
    func getPendingTransactionInfo() -> (PacksModel, String?,String? ,String? ,InAppPaymentRequest) {
        
        var txnid : String?  = nil
        var paymentStatus  = "failure"
        var message  = "Known issue"
        
        if let txnidValue = UserDefaults.standard.object(forKey: "key_trans_id") {
            txnid = txnidValue as? String
        }
        if let paymentStatusValue = UserDefaults.standard.object(forKey: "key_payment_status") {
            paymentStatus = paymentStatusValue as! String
        }
        if let messageValue = UserDefaults.standard.object(forKey: "key_message") {
            message = messageValue as! String
        }
        
        var pack = PacksModel()
        
        if let packName = UserDefaults.standard.object(forKey: "key_pack_name") {
            pack.packName = packName as? String
        }
        if let packId = UserDefaults.standard.object(forKey: "key_pack_id") {
            pack.packId = packId as? String
        }
        if let inappProductId = UserDefaults.standard.object(forKey: "productId") {
            pack.productId = inappProductId as? String
        }
        
        let paymentRequest = InAppPaymentRequest()
        if let receipt = UserDefaults.standard.object(forKey: "key_receipt") {
            paymentRequest.receipt = receipt  as! String
        }
        if let txnStatus = UserDefaults.standard.object(forKey: "key_txn_status") {
            paymentRequest.txnStatus = txnStatus as! String
        }
        if let paymentType = UserDefaults.standard.object(forKey: "key_payment_type") {
            paymentRequest.paymentType = paymentType as! String
        }
        if let transactionId = UserDefaults.standard.object(forKey: "key_transaction_id") {
            paymentRequest.transactionId = transactionId as! String
        }
        if let txnid = UserDefaults.standard.object(forKey: "key_txn_id") {
            paymentRequest.txnid = txnid as? String
        }
        print("getPendingTransactionInfo for txnid = \(String(describing: txnid))")
        
        return (pack,txnid,paymentStatus,message,paymentRequest)
    }
    
    func removeObjectForKey(key : String) {
        
        if UserDefaults.standard.object(forKey: key) != nil {
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}

//
//  InAppPurchaseManager.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 01/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class InAppPurchaseManager: NSObject {
    
    
    private let TAG = "InAppPurchaseManager:: "
    
    class var sharedInstance: InAppPurchaseManager {
        
        struct Singleton {
            static let instance = InAppPurchaseManager()
        }
        return Singleton.instance
    }
    
    override  init(){
        super.init();
    }
    
    func purchaseProductAndUpdateServer(pack : PacksModel, paymentRequest :InAppPaymentRequest, completion : ((_ status : Bool, _ message : String) -> Void)? ){

        print("purchaseProductAndUpdateServer")

            InAppManager.sharedInstance.purchaseSubscription(productId: pack.productId! , completion: { (status, message, transaction, receipt,transactionId) in
                if status {
                    //CallOUserManager.sharedInstance.setUserStatus(userStatus: .Subscribed)
                    paymentRequest.receipt = receipt
                    paymentRequest.transactionId = transactionId
                    paymentRequest.txnStatus = "success"
                    print("payment receipt - \(receipt)")

                    InAppSharedPrefrance().saveTransactionInfo(pack: pack, transId: nil, paymentStatus: "success", message: nil , paymentRequest: paymentRequest)
                    InAppManager.sharedInstance.finishTransaction(transaction: transaction)

                    self.notifyServer(receipt: receipt,paymentRequest : paymentRequest, completion: { (status, message) in
                        if(status) {
                        }
                        if completion != nil{
                            completion!(status,message)
                        }
                    })
                }else{

                    if(paymentRequest.txnid != nil){
                        InAppSharedPrefrance().saveTransactionInfo(pack: pack, transId: paymentRequest.txnid!, paymentStatus: "failure", message: message,paymentRequest : InAppPaymentRequest())
                    }
//                    self.checkAndClearPendingTransaction()
                    if completion != nil{
                        completion!(false,message)
                    }
                }
            })

    }

    func notifyServer(receipt: String, paymentRequest :InAppPaymentRequest, completion : ((_ status : Bool, _ message : String) -> Void)? ){
        RequestManager.shared.notifyServerForPurchase(receipt: receipt, paymentRequest :paymentRequest, onCompletion: { (responseJson) in
            print("\(self.TAG)   notifyServer() success : \(String(describing: responseJson))")
            let response = Response.init(json: responseJson)
            if completion != nil{
                completion!((response.status != nil),response.reason ?? "not found " )
            }
            
            
        }, onFailure: { (error) in
            print("\(self.TAG)   notifyServer() error : \(String(describing: error?.localizedDescription))")
            completion!(false,(String(describing: error?.localizedDescription)))
        })
        
    }
        
        

//        InAppPaymentRequest.sharedInstance.buyPack(pack: pack, paymentRequest : paymentRequest)  { (response) in
//
//            var status = false
//            var message = CallOMessages.PACK_BUY_FAILED
//
//            if (response?.httpStatus)! {
//                CallOSharedPreference().clearTransactionStatus()
//            }
//
//            if response?.status == RequestStatus.success
//            {
//                status = true
//                let reason = response?.message
//                if reason != nil && (reason?.count)! > 0 {
//                    message = reason!
//                }else{
//                    message = CallOMessages.PACK_BUY_SUCCESS
//                }
//            }else{
//                let reason = response?.reason
//                if reason != nil && (reason?.count)! > 0 {
//                    message = reason!
//                }
//            }
//            if completion != nil{
//                completion!(status,message)
//            }
//        }
//    }
//
//    func checkAndClearPendingTransaction() {
//
//        let sharedPreference = InAppSharedPrefrance()
//        if(sharedPreference.getTransactionStatus()) {
//
//            let (pack,txnid,paymentStatus,message,paymentRequest) = sharedPreference.getPendingTransactionInfo()
//            print("Clear pending transaction for txnid = \(String(describing: txnid))")
//
//            if paymentRequest.txnStatus == "success" {
//
//                print("notify pending payment to server for transactionId = \(paymentRequest.transactionId)")
//                self.notifyServer(pack: pack, paymentRequest : paymentRequest,  completion: { (status, message) in
//                    if(status) {}
//                })
//            }else if txnid != nil {
//
//                print("savePaymentMadeByUser for txnid = \(String(describing: txnid))")
//
//                InAppSharedPrefrance.sharedInstance.savePaymentMadeByUser(pack: pack, txnid: txnid!, paymentStatus: paymentStatus! ,message : message!, completion: { (response) in
//
//                    if response?.status == RequestStatus.success
//                    {
//                        sharedPreference.clearTransactionStatus()
//                    }
//                })
//            }
//        }
//    }
}


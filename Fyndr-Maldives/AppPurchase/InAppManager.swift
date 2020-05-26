//
//  InAppManager.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 25/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

import UIKit
import SwiftyStoreKit
import StoreKit

class InAppManager: NSObject {
    
    let sharedSecret = "3e31d7dd63734e51bdbbda11d2430139"
    
    class var sharedInstance: InAppManager {
        struct Singleton {
            static let instance = InAppManager()
        }
        return Singleton.instance
    }
    
    override  init(){
        super.init();
    }
    
    //Some devices and accounts may not permit an in-app purchase
    func canMakePayments() -> Bool {
        return SwiftyStoreKit.canMakePayments
    }
    
    func registerTransactionObserver() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    break
                }
            }
        }
    }
    
    func retrieveProductInfo(productIds: Set<String>, completion : ((_ status : Bool, _ results : [String:String]?, _ message : String) -> Void)? ) {
        
        print("retrieveProductInfo : productId = ",productIds)
        
        SwiftyStoreKit.retrieveProductsInfo(productIds) { result in
            
            if result.retrievedProducts.count > 0 {
                var priceList = [String:String]()
                
                for product in result.retrievedProducts{
                    let priceString = product.localizedPrice!
                    print("Product: \(product.localizedDescription), price: \(priceString)")
                    priceList[product.productIdentifier] = priceString
                }
                completion!(true,priceList,"")
                
            }else if result.invalidProductIDs.count > 0{
                print("Could not retrieve product info, Invalid product identifier: \(String(describing: result.invalidProductIDs.first))")
                if completion != nil{
                    completion!(false,nil,"Could not retrieve product info, Invalid product identifier: \(String(describing: result.invalidProductIDs.first))")
                }
            }else{
                print("Error: \(String(describing: result.error))")
                if completion != nil{
                    completion!(false,nil,(result.error?.localizedDescription)!)
                }
            }
        }
    }
    
    func getLocalReceiptData() -> Data {
        let receipt =  SwiftyStoreKit.localReceiptData
        
        if receipt != nil{
            return receipt! as Data
        }
        return Data()
    }
    
    func validateReceiptData(){
        var appleValidator : AppleReceiptValidator
        #if DEBUG
        appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret)
        #else
        appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        #endif
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { result in
            
            if case .success = result {
                print("Validate receipt Data successfully")
            }
            if case .error(let error) = result {
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
    }
    
    func refreshReceipt() {
        
        //        SwiftyStoreKit.refreshReceipt { result in
        //            switch result {
        //            case .success(let receiptData):
        //                print("Receipt refresh success: \(receiptData.base64EncodedString)")
        //            case .error(let error):
        //                print("Receipt refresh failed: \(error)")
        //            }
        //        }
    }
    
    
    func verifySubscription(){
        
        var appleValidator : AppleReceiptValidator
        #if DEBUG
        appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret)
        #else
        appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        #endif
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                
                var latestReceipt = ""
                if receipt["latest_receipt"] != nil {
                    latestReceipt = receipt["latest_receipt"] as! String
                }
                
                print("latestReceipt : \n\(latestReceipt)")
                
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: "magiccall.us.weeklyfreetrial", inReceipt: receipt, validUntil:  NSDate() as Date)
                switch purchaseResult {
                case .purchased(let expiresDate):
                    print("Product is valid until \(expiresDate)")
                case .expired(let expiresDate):
                    print("Product is expired since \(expiresDate)")
                case .notPurchased:
                    print("This product has never been purchased")
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    
    //Atomic: to be used when the content is delivered immediately.
    func purchaseProduct(productId : String, completion : ((_ status : Bool, _ message : String) -> Void)? ){
        
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
            switch result {
            case .success(let product):
                print("Purchase Success: \(product.productId)")
                
                if completion != nil{
                    completion!(true,"Purchase Success: \(product.productId)")
                }
                
            case .error(let error):
                
                print("Purchase Failed: \(error)")
                var errorMessage = error.localizedDescription
                
                switch error.code {
                case .unknown:
                    errorMessage = "Unknown error. Please contact support"
                case .clientInvalid:
                    errorMessage = "Not allowed to make the payment"
                case .paymentCancelled:
                    errorMessage = "Request cancelled"
                case .paymentInvalid:
                    errorMessage = "The purchase identifier was invalid"
                case .paymentNotAllowed:
                    errorMessage = "The device is not allowed to make the payment"
                case .storeProductNotAvailable:
                    errorMessage = "The product is not available in the current storefront"
                case .cloudServicePermissionDenied:
                    errorMessage = "Access to cloud service information is not allowed"
                case .cloudServiceNetworkConnectionFailed:
                    errorMessage = "Could not connect to the network"
                case .cloudServiceRevoked:
                    errorMessage = "User has revoked permission to use this cloud service"
                default:
                    errorMessage = "unone error code \(error.code)"
               
                }
                print("purchaseProduct() Purchase Failed reason : \(errorMessage)")
                
                if completion != nil{
                    completion!(false,errorMessage)
                }
            }
        }
    }
    
    //Atomic: to be used when the content is delivered immediately.
    func purchaseSubscription(productId : String, completion : ((_ status : Bool, _ message : String, _ transaction: Any? , _ receipt : String, _ transactionId : String) -> Void)? ){
        print("purchaseSubscription : productId ", productId)
        
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
            
            var transaction : Any?
            var transactionId = ""
            
            switch result {
            case .success(let product):
                print("Purchase Success: \(product.productId)")
                
                var appleValidator : AppleReceiptValidator
                #if DEBUG
                appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: self.sharedSecret)
                #else
                appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedSecret)
                #endif
                
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                    switch result {
                    case .success(let receipt):
                        // Verify the purchase of a Subscription
                        var message = "Purchase Success";
                        
                        var latestReceipt = ""
                        if receipt["latest_receipt"] != nil {
                            latestReceipt = receipt["latest_receipt"] as! String
                        }
                        let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productId, inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let items):
                            // message = "\(productId) is valid until \(expiryDate)\n\(items)\n"
                            message = "\(productId) is valid until \(expiryDate)"
                            if items.count > 0 {
                                if let receiptItem : ReceiptItem = items.first {
                                    transactionId = receiptItem.originalTransactionId
                                }
                            }
                            print("purchased transaction details ", "\(productId) is valid until \(expiryDate)\n\(items)\n")
                            //print("transaction Id ", transactionId)
                            // print("items  ", items)
                            
                        case .expired(let expiryDate, _):
                            //message = "\(productId) is expired since \(expiryDate)\n\(items)\n"
                            message = "\(productId) is expired since \(expiryDate)"
                            print("expired transaction details", "\(productId) is valid until \(expiryDate)")
                            
                        case .notPurchased:
                            message = "The user has never purchased \(productId)"
                        }
                        
                        if product.needsFinishTransaction {
                            // SwiftyStoreKit.finishTransaction(product.transaction)
                            transaction = product.transaction
                        }
                        
                        //                        let paymentTransaction = product.transaction as! SKPaymentTransaction
                        //                        if let transactionIdentifier = paymentTransaction.transactionIdentifier
                        //                        {
                        //                            print("transaction Id ", transactionIdentifier)
                        //                            transactionId = transactionIdentifier
                        //                        }
                        
                        if completion != nil{
                            completion!(true,message,transaction,latestReceipt,transactionId)
                        }
                        
                    case .error(let error):
                        print("Receipt verification failed: \(error)")
                        
                        if completion != nil{
                            completion!(false,"Receipt verification failed: \(error.localizedDescription)",transaction,"",transactionId)
                        }
                    }
                }
                
                //                if completion != nil{
                //                    completion!(true,"Purchase Success: \(product.productId)")
                //                }
                
            case .error(let error):
                
                print("purchaseSubscription() Purchase Failed: \(error)")
                var errorMessage = error.localizedDescription
                
                switch error.code {
                case .unknown:
                    //errorMessage = "Unknown error. Please contact support"
                    if error.localizedDescription.contains("Cannot connect to iTunes Store") {
                        errorMessage = "Something went wrong Please try after sometime"
                    }else{
                        errorMessage = "Something went wrong Please try after sometime"
                    }
                case .clientInvalid:
                    errorMessage = "Not allowed to make the payment"
                case .paymentCancelled:
                    errorMessage = "Request cancelled"
                case .paymentInvalid:
                    errorMessage = "The purchase identifier was invalid"
                case .paymentNotAllowed:
                    errorMessage = "The device is not allowed to make the payment"
                case .storeProductNotAvailable:
                    errorMessage = "The product is not available in the current storefront"
                case .cloudServicePermissionDenied:
                    errorMessage = "Access to cloud service information is not allowed"
                case .cloudServiceNetworkConnectionFailed:
                    errorMessage = "Could not connect to the network"
                case .cloudServiceRevoked:
                    errorMessage = "User has revoked permission to use this cloud service"
                default:
                    errorMessage = "unone error code \(error.code)"

                }
                print("purchaseSubscription() Purchase Failed reason : \(errorMessage)")
                
                if completion != nil{
                    completion!(false,errorMessage,transaction,"",transactionId)
                }
            }
        }
    }
    
    func finishTransaction(transaction: Any?) {
        guard transaction is SKPaymentTransaction else {
            print("Object is not a SKPaymentTransaction")
            return
        }
        SwiftyStoreKit.finishTransaction((transaction as? SKPaymentTransaction)!)
    }
    
    
    //Non-Atomic: to be used when the content is delivered by the server.
    func purchaseProductNonAtomic(productId : String, completion : ((_ status : Bool, _ message : String, _ transaction: Any? , _ receipt : String, _ transactionId : String) -> Void)? ){
        print("purchaseProductNonAtomic : \(productId)")
    
        //SwiftyStoreKit.purchaseProduct(productId, atomically: false)
            SwiftyStoreKit.purchaseProduct(productId) { result in
            
            print("purchaseProductNonAtomic : purchaseProduct ", result)

            var transaction : Any?
            var transactionId = ""
            
            switch result {
            case .success(let product):
                
                var message = "Purchase Success";
                var receiptString = "";
                var status = false
                
                var appleValidator : AppleReceiptValidator
                #if DEBUG
                appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: self.sharedSecret)
                #else
                appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedSecret)
                #endif
                
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                    switch result {
                    case .success(let receipt):
                        // Verify the purchase of Consumable or NonConsumable
                        let purchaseResult = SwiftyStoreKit.verifyPurchase(
                            productId: productId,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let receiptItem):
                            print("\(productId) is purchased: \(receiptItem)")
                            
                            if receipt["latest_receipt"] != nil {
                                receiptString = receipt["latest_receipt"] as! String
                            }
                            status = true
                        case .notPurchased:
                            print("The user has never purchased \(productId)")
                        }
                    case .error(let error):
                        print("Receipt verification failed: \(error)")
                        message = error.localizedDescription
                    }
                    
                    // fetch content from your server, then:
                    if product.needsFinishTransaction {
                        // SwiftyStoreKit.finishTransaction(product.transaction)
                        transaction = product.transaction
                    }
                    
                    let paymentTransaction = product.transaction as! SKPaymentTransaction
                    if let transactionIdentifier = paymentTransaction.transactionIdentifier
                    {
                        print("transaction Id ", transactionIdentifier)
                        transactionId = transactionIdentifier
                    }
                    
                    print("Purchase Success: \(product.productId)")
                    
                    if completion != nil{
                        completion!(status,message,transaction,receiptString,transactionId)
                    }
                }
            case .error(let error):
                
                print("Purchase Failed: \(error)")
                var errorMessage = error.localizedDescription
                
                switch error.code {
                case .unknown:
                    //errorMessage = "Unknown error. Please contact support"
                    errorMessage = "Something went wrong Please try after sometime"
                case .clientInvalid:
                    errorMessage = "Not allowed to make the payment"
                case .paymentCancelled:
                    errorMessage = "User cancelled the request"
                case .paymentInvalid:
                    errorMessage = "The purchase identifier was invalid"
                case .paymentNotAllowed:
                    errorMessage = "The device is not allowed to make the payment"
                case .storeProductNotAvailable:
                    errorMessage = "The product is not available in the current storefront"
                case .cloudServicePermissionDenied:
                    errorMessage = "Access to cloud service information is not allowed"
                case .cloudServiceNetworkConnectionFailed:
                    errorMessage = "Could not connect to the network"
                case .cloudServiceRevoked:
                    errorMessage = "User has revoked permission to use this cloud service"
                default:
                    errorMessage = "unone error code \(error.code)"
                }
                print("purchaseProductNonAtomic() Purchase Failed reason: \(errorMessage)")
                
                if completion != nil{
                    completion!(false,errorMessage,transaction,"",transactionId)
                }
            }
        }
    }
    
    
    //Atomic: to be used when the content is delivered immediately.
    func restorePurchases(completion : ((_ status : Bool, _ message : String) -> Void)? ){
        
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                if completion != nil{
                    completion!(false,"Restore Failed: \(results.restoreFailedPurchases)")
                }
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                if completion != nil{
                    completion!(true,"")
                }
            }
            else {
                print("Nothing to Restore")
                
                if completion != nil{
                    completion!(true,"Nothing to Restore")
                }
            }
        }
    }
    
    //Non-Atomic: to be used when the content is delivered by the server..
    func restorePurchasesNonAtomic(completion : ((_ status : Bool, _ message : String) -> Void)? ){
        
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                if completion != nil{
                    completion!(false,"Restore Failed: \(results.restoreFailedPurchases)")
                }
            }
            else if results.restoredPurchases.count > 0 {
                
                for product in results.restoredPurchases {
                    
                    print("product : \(product.productId) needsFinishTransaction : \(product.needsFinishTransaction)" )
                    
                    // fetch content from your server, then:
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                }
                print("Restore Success: \(results.restoredPurchases)")
                if completion != nil{
                    completion!(true,"")
                }
            }
            else {
                print("Nothing to Restore")
                
                if completion != nil{
                    completion!(true,"Nothing to Restore")
                }
            }
        }
    }
    
}

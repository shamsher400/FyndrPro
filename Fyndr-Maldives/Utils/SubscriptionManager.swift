//
//  SubscriptionManager.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 06/11/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation




enum SubscriptionState : String{
    case PENDING = "PENDING"
    case FAILED = "FAILED"
    case SUCCESS = "SUCCESS"
}

class SubscriptionManager {
    let TAG = "SubscriptionManager ::->"
    var isInApp = false
    var retryCheckSubCount = 0
    var timer = Timer()
    var isTimerRunning = false
    var seconds = 1
    var mPackId = ""
    var orderId = ""
    
    var currentViewController: ViewController?
    
    
    class var sharedInstance: SubscriptionManager {
        
        struct Singleton {
            static let instance = SubscriptionManager()
        }
        return Singleton.instance
    }
    
    private init(){
        
    }
    
    
    private func initilizeAllVeribales() {
        isInApp = false
        retryCheckSubCount = 0
        isTimerRunning = false
        orderId = ""
        mPackId = ""
    }
    
    func savePendingSubscription(packId: String, orderId: String) {
        print("\(TAG) savePendingSubscription() packId \(packId), orderId \(orderId)")
        if packId != "" {
            self.orderId = orderId
            savePendingPurchasePacks(packId: packId, orderId: orderId, state: SubscriptionState.PENDING.rawValue)
        }
    }
    
    
    func handleSubscriptionCallBack() {
        print("\(TAG) handleSubscriptionCallBack() called from notification call count: timerCount \(retryCheckSubCount)  isInApp \(isInApp)")
        if !isTimerRunning {
            if retryCheckSubCount < 3 {
                isInApp  = false
                isTimerRunning = true
                startTimer()
            }else {
                timer.invalidate()
                self.initilizeAllVeribales()
            }
        }
    }
    
    func handleSubscriptionCallBack(packId: String, orderId: String) {
        print("\(TAG) handleSubscriptionCallBack() called from notification call count: timerCount \(retryCheckSubCount)  isInApp \(isInApp)")
        if !isTimerRunning {
            if retryCheckSubCount < 3 {
                savePendingPurchasePacks(packId: packId, orderId: orderId, state: SubscriptionState.PENDING.rawValue)
                isInApp  = true
                isTimerRunning = true
                startTimer()
            }else {
                timer.invalidate()
                self.initilizeAllVeribales()
            }
        }
    }
    
    func savePendingPurchasePacks(packId: String, orderId: String, state: String){
        var pendingSubscription = PendingPackModel.init()
        pendingSubscription.orderId = orderId
        pendingSubscription.packId = packId
        pendingSubscription.status = state
        pendingSubscription.save()
    }
    
    func getPendingPackDertails() -> PendingPackModel? {
        let pendingPack = PendingPackModel.init()
            return pendingPack.getPendingPackModel()
    }

    private func startTimer() {
        print("\(TAG)  startTimer() retryCheckSubCount \(retryCheckSubCount)")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds  = seconds - 1
        if seconds <= 0 {
            seconds = 20
            checkSubApi(packId: mPackId, orderId: self.orderId)
        }
    }
    
    private func checkSubApi(packId: String, orderId: String){
        print("\(TAG) checkSubApi()  packId \(packId)  orderId \(orderId)")
        retryCheckSubCount = +1
        if Reachability.isInternetConnected()
        {
            let uniqeId = Util.getProfile()?.uniqueId ?? ""
            RequestManager.shared.checkSubscriptionWithOrderId(unique: uniqeId, orderId: orderId, onCompletion: { (response) in
                let checkSubModel = CheckSubscriptionResponse.init(json: response)
                if checkSubModel.status?.lowercased() == "success" {
                    if checkSubModel.orderStatus?.contains(SubscriptionState.SUCCESS.rawValue ) ?? false {
                        checkSubModel.save()
                        self.savePendingSubscription(packId: "", orderId: "")
                        self.notifyForUpdateView(packId: packId, subStatus: SubscriptionState.SUCCESS)
                        if self.isInApp {
                            if let successMessage = checkSubModel.reason{
                                self.showSubscriptionMessage(message: successMessage)
                            }
                        }
                        self.initilizeAllVeribales()
                        self.timer.invalidate()
                    }else if checkSubModel.orderStatus?.contains(SubscriptionState.FAILED.rawValue ) ?? false{
                        self.notifyForUpdateView(packId: packId, subStatus: SubscriptionState.FAILED)
                        if self.isInApp {
                            if let successMessage = checkSubModel.reason{
                                self.showSubscriptionMessage(message: successMessage)
                            }
                        }
                        self.initilizeAllVeribales()
                        self.timer.invalidate()
                    }else if checkSubModel.orderStatus?.contains(SubscriptionState.PENDING.rawValue ) ?? false{
                        self.isTimerRunning = false
                        self.handleSubscriptionCallBack(packId: packId, orderId: orderId)
                    }else {
                        checkSubModel.save()
                        self.savePendingPurchasePacks(packId: "", orderId: "", state: SubscriptionState.PENDING.rawValue)
                        
                    }
                    checkSubModel.save()
                    self.initilizeAllVeribales()
                    self.timer.invalidate()
                }else {
                    self.isTimerRunning = false
                    self.handleSubscriptionCallBack()
                }
                //print("\(self.TAG) Fyndr :checkSubscriptionResponse - \(response)")
            })
            { (error) in
                self.isTimerRunning = false
                self.handleSubscriptionCallBack()
                print("DashboardViewController: checkSubscriptionRequest() - error: \(String(describing: error?.localizedDescription))")
            }
        }else {
            print("Fyndr :checkSubscriptionRequest - not connected to internet")
        }
    }

    private func showSubscriptionMessage(message: String) {
        if APP_DELEGATE.appCurrentState == AppState.froground.rawValue {
            if let vc = APP_DELEGATE.getTopViewController() {
                AlertView.init().showAlert(vc: vc, message: message)
            }else {
                // show app notifications
            }
        }else {
            // Show in app notifications
        }
    }
    
    
    private func notifyForUpdateView(packId: String,subStatus: SubscriptionState){
        var myDisc: [AnyHashable : Any] = ["" : ""]
        myDisc["packId"] = packId
        myDisc["orderId"] = orderId
        myDisc["subStatus"] = subStatus.rawValue
        NotificationCenter.default.post(name: Notification.Name("subscriptionNotify"), object: nil, userInfo: myDisc)
    }
    
    
}

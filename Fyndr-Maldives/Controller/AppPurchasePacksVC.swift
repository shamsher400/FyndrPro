//
//  AppPurchasePacksVC.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 25/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import SafariServices


class AppPurchasePacksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewTermAndConditions: UIView!
    var packModelArray = [PacksModel]()
    @IBOutlet weak var tblProductArray: UITableView!
    @IBOutlet weak var txtSub: UITextView!
    
    let TAG = "AppPurchasePacksVC :: "
    let tableCellHeight = SCREEN_HEIGHT * 0.2 <= 110 ? SCREEN_HEIGHT * 0.2 : 110
    
    var packModel: PacksModel?
    var isNeedToBeCheckSub = false
    
    var transactionId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("M_SUBSCRIPTION", comment: "")
        tblProductArray.delegate = self
        tblProductArray.dataSource = self
        getPacksFromServer()
        Util.showLoader()
        
        initSubscriptionNote()
        if let myProfile = Util.getProfile() {
            if myProfile.profileType == ProfileType.OPERATOR.rawValue {
                viewTermAndConditions.isHidden = true
            }else {
                viewTermAndConditions.isHidden = false
            }
        }
        
    }
    
    
    
    private func updateView(packType: String) {
        if packType == PackType.operatorPack.rawValue {
            viewTermAndConditions.isHidden = true
        }else {
            viewTermAndConditions.isHidden = false
        }
    }
    
    @objc func receiveNessage(notification : Notification) {
        let dic = notification.userInfo
        
        if let dics = dic {
            var pendingPackId = PendingPackModel.init()
            pendingPackId = pendingPackId.getPendingPackModel() ?? PendingPackModel.init()
            let packId = dics["packId"] as? String ?? ""
            pendingPackId.packId = packId
            pendingPackId.orderId = dics["orderId"] as? String ?? ""
            let status =  dics["status"] as? String ?? ""
            pendingPackId.status = status
            pendingPackId.save()
            sendSubscriptionStatusEvent(packId: packId, status: status)
            tblProductArray.reloadData()
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "subscriptionNotify"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNessage(notification:)), name: NSNotification.Name(rawValue: "subscriptionNotify"), object: nil)
        self.sendOpenScreenEvent()
        if isNeedToBeCheckSub {
            isNeedToBeCheckSub = false
            checkSubApi( orderId: transactionId)
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppPurchaseCell") as! AppPurchaseCell
        
        let dataModel = packModelArray[indexPath.row]
        
        
        cell.lblPackTitle.text = dataModel.packName
        cell.lblPackDiscription.text = dataModel.description
        
        if dataModel.shortDescription != nil && dataModel.shortDescription != ""{
            cell.lblPackShortDesc.isHidden = false
            cell.lblPackShortDesc.text = dataModel.shortDescription
        }else {
            cell.lblPackShortDesc.isHidden = true
        }
        
        if let pendingPackModel = SubscriptionManager.sharedInstance.getPendingPackDertails() {
            if pendingPackModel.packId == dataModel.packId {
                if pendingPackModel.status == SubscriptionState.PENDING.rawValue {
                    cell.btnPackSelected.setTitle(NSLocalizedString("M_PENDING", comment: ""), for: .normal)
                    cell.btnPackSelected.backgroundColor = UIColor.clear
                    cell.btnPackSelected.setTitleColor(UIColor.customOrange, for: .normal)
                }else if pendingPackModel.status == SubscriptionState.SUCCESS.rawValue {
                    cell.btnPackSelected.setTitle(NSLocalizedString("M_ACTIVE", comment: ""), for: .normal)
                    cell.btnPackSelected.backgroundColor = UIColor.clear
                    cell.btnPackSelected.setTitleColor(UIColor.green, for: .normal)
                }else {
                    cell.btnPackSelected.setTitle(NSLocalizedString("M_BUY_NOW", comment: ""), for: .normal)
                    cell.btnPackSelected.backgroundColor = UIColor.appPrimaryColor
                    cell.btnPackSelected.setTitleColor(UIColor.appPrimaryBlueColor, for: .normal)
                }
            }else {
                cell.btnPackSelected.setTitle(NSLocalizedString("M_BUY_NOW", comment: ""), for: .normal)
                cell.btnPackSelected.backgroundColor = UIColor.appPrimaryColor
                cell.btnPackSelected.setTitleColor(UIColor.appPrimaryBlueColor, for: .normal)
                
            }
        }else {
            cell.btnPackSelected.setTitle(NSLocalizedString("M_BUY_NOW", comment: ""), for: .normal)
            cell.btnPackSelected.backgroundColor = UIColor.appPrimaryColor
            cell.btnPackSelected.setTitleColor(UIColor.appPrimaryBlueColor, for: .normal)
        }
        
        cell.btnPackSelected.tag = indexPath.row
        cell.btnPackSelected.addTarget(self, action: #selector(startPayment), for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCellHeight
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        var pendingPack = PendingPackModel.init()
        pendingPack = pendingPack.getPendingPackModel() ?? PendingPackModel.init()
        if pendingPack.packId == nil || pendingPack.packId == "" || pendingPack.status == SubscriptionState.FAILED.rawValue{
            startPaymentAndVerify(index: index)
        }
    }
    
    
    @objc func startPayment(_ sender : UIButton)
    {
        let index = sender.tag
        var pendingPack = PendingPackModel.init()
        pendingPack = pendingPack.getPendingPackModel() ?? PendingPackModel.init()
        if pendingPack.packId == nil || pendingPack.packId == "" || pendingPack.status == SubscriptionState.FAILED.rawValue{
            startPaymentAndVerify(index: index)
        }
    }
    
    private func startPaymentAndVerify(index: Int){
        let model = packModelArray[index]
        packModel = model
        packSelectionEvent(packId: packModel?.packId ?? "")
        if model.packType == PackType.storePack.rawValue {
            self.verifiedProductFromAppStore(productIDs: [model.productId ?? ""], packType: .storePack )
            Util.showLoader()
        }else {
            verifyOperatorPurchaseConnectivity(packId: model.packId ?? "", packType: .operatorPack)
            Util.showLoader()
        }
    }
    
    private func verifyOperatorPurchaseConnectivity(packId: String , packType: PackType) {
        if NetworkReachability.isMobileNetwork() {
            Util.showLoader()
            purchaseOperatorSubscriptionPacks(packId: packId, packType: packType)
        }else {
            Util.hideLoader()

            let alertView = AlertView()
            alertView.delegate = self
            alertView.showAlert(vc: self, title: "", message: NSLocalizedString("M_WIFI_DESABLE_ALERT", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), tag: 9)
        }
    }
    
    
    private func getPacksFromServer() {
        RequestManager.shared.getPacksFromServer( onCompletion: { (responseJson) in
            let packResponse = AppPacksResponse.init(json: responseJson)
            DispatchQueue.main.async {
                if packResponse.status?.lowercased() == "success" {
                    if let packs = packResponse.packs {
                        self.updateView(packType: packs.last?.packType ?? "")
                        self.packModelArray = packs
                        self.tblProductArray.reloadData()
                        Util.hideLoader()
                    }else {
                        print("\(self.TAG) getPacksFromServer() data is null")
                    }
                }else {
                    AlertView.init().showAlert(vc: self, title: "", message: packResponse.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
                    print("\(self.TAG) getPacksFromServer() failure \(packResponse.reason ?? "reson not getting" )")
                    Util.hideLoader()
                }
            }
        }, onFailure: { (error) in
            Util.hideLoader()
            print("\(self.TAG)   getPacksFromServer() error : \(String(describing: error?.localizedDescription))")
            
        })
    }
    
    private func purchaseOperatorSubscriptionPacks(packId: String , packType: PackType) {
        Util.showLoader()
        RequestManager.shared.purchaseOperatorPscks(packId: packId, onCompletion: { (responseJson) in
            DispatchQueue.main.async {
                let purchasePackModel = PurchasePackResponse.init(json: responseJson)
                if purchasePackModel.status?.lowercased() == "success" {
                    if packType == PackType.storePack {
                        self.startInappPayment(txtnId: purchasePackModel.orderId ?? "" ,packType: packType, packId: packId )
                    }else {
                        print("\(self.TAG) purchaseOperatorSubscriptionPacks()  handle operator pack purchase pending ")
                        DispatchQueue.main.async {
                            Util.hideLoader()
                            self.checkSubApi()
                        }
                    }
                }else {
                    AlertView.init().showAlert(vc: self, title: "", message: purchasePackModel.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
                    Util.hideLoader()
                    print("\(self.TAG) purchaseOperatorSubscriptionPacks() ")
                }
            }
        }, onFailure: { (error) in
            Util.hideLoader()
            let alertView = AlertView()
            alertView.delegate = self
            alertView.showAlert(vc: self, title: "", message: NSLocalizedString("v", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
            print("\(self.TAG) error : \(String(describing: error?.localizedDescription))")
        })
    }
}

extension AppPurchasePacksVC: SFSafariViewControllerDelegate {
    private func openSubscriptioWebView(packId: String, subscriptionId: String, transactionUrl: String) {
            let urlString = "https://www.magiccall.co/opcos/lka/ioslka.php"
            if let url = URL(string: urlString) {
                transactionId = subscriptionId;
                isNeedToBeCheckSub = true
                let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                vc.delegate = self

                present(vc, animated: true)
            }
        }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print(self.TAG  + "safariViewControllerDidFinish() ")
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        print(self.TAG  + "safariViewController() \(URL.absoluteString)")
        
    }
}

// verified packs from App store
extension AppPurchasePacksVC: SKProductsRequestDelegate{
    
    private func verifiedProductFromAppStore(productIDs : [String], packType: PackType) {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("\(self.TAG)  Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.first != nil {
            purchaseOperatorSubscriptionPacks(packId: packModel?.packId ?? "", packType: .storePack)
            print("There are products. \(response.products.count)")
        }
        else {
            Util.hideLoader()
            AlertView.init().showAlert(vc: self, title: "", message:  NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
            print("There are no products.")
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions as! [SKPaymentTransaction] {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func startInappPayment(txtnId: String , packType: PackType, packId: String)
    {
        let paymentRequest = InAppPaymentRequest()
        paymentRequest.paymentType = packType.rawValue
        paymentRequest.receipt = ""
        paymentRequest.txnid = txtnId
        paymentRequest.txnStatus = "failure"
        InAppPurchaseManager.sharedInstance.purchaseProductAndUpdateServer(pack: self.packModel! ,paymentRequest : paymentRequest) { (status, message) in
            DispatchQueue.main.async {
                Util.hideLoader()
                if status {
                    var pendingPack = PendingPackModel.init()
                    pendingPack = pendingPack.getPendingPackModel() ?? PendingPackModel.init()
                    pendingPack.packId = packId
                    pendingPack.status = SubscriptionState.SUCCESS.rawValue
                    pendingPack.save()
                    SubscriptionManager.sharedInstance.handleSubscriptionCallBack()
                }else {
                    var pendingPack = PendingPackModel.init()
                    pendingPack = pendingPack.getPendingPackModel() ?? PendingPackModel.init()
                    pendingPack.packId = packId
                    pendingPack.status = SubscriptionState.FAILED.rawValue
                    pendingPack.save()
                }
                self.tblProductArray.reloadData()
                let alertView = AlertView()
                alertView.delegate = self
                alertView.showAlert(vc: self, title: "", message: message, okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
                print("------------  status- \(status)   message\(message)")
            }
        }
    }
}

extension AppPurchasePacksVC: AlertViewDelegate {
    func okButtonAction(tag: Int) {
        
        if tag == 0 {
            self.navigationController?.popViewController(animated: true)
        }else if tag == 9 {
            openWifiSettings()
        }
    }
    
    func cancelButtonAction(tag: Int) {
        if tag == 9 {
        }
    }
    
    
    private func openWifiSettings () {
        sendOpenSettingScreenEvent()
        let urlSetting = URL.init(string: UIApplication.openSettingsURLString)
        UIApplication.shared.open(urlSetting!, options: [:], completionHandler: nil)
    }
}


extension AppPurchasePacksVC: UITextViewDelegate {
    
    func initSubscriptionNote(){
        
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributedOriginalText = NSMutableAttributedString(string: NSLocalizedString("M_TERM_AND_CONDITIONS_MESSAGE", comment: ""))
        
        let boldStr = NSLocalizedString("M_TERM_CONDITIONS_RECURRING_BILLING", comment: "")
        let termOfService = NSLocalizedString("M_TERM_CONDITIONS_TERM_OF_SERVICE", comment: "")
        let privacyPolicy =  NSLocalizedString("M_TERM_CONDITIONS_PRIVACY_POLICY", comment: "")
        
        let fullRange = NSMakeRange(0, attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.appFont(weight: .regular, size: 12), range: fullRange)
        
        let boldStrRange = attributedOriginalText.mutableString.range(of: boldStr)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.appFont(weight: .bold, size: 12), range: boldStrRange)
        
        let termOfServiceRange = attributedOriginalText.mutableString.range(of: termOfService)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.appFont(weight: .bold, size: 12), range: termOfServiceRange)
        
        
        // TODO: add language code
        
        let finalTermUrl = TERM_OF_SERICE_URL + "?lang=\(Util.getPhoneLang())"
        let finalPrivecyUrl = PRIVACY_URL + "?lang=\(Util.getPhoneLang())"
        
        print("TermServiceUrl - \(finalTermUrl)  finalPrivecyUrl - \(finalPrivecyUrl)")
        
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: finalTermUrl, range: termOfServiceRange)
        
        let privacyPolicyRange = attributedOriginalText.mutableString.range(of: privacyPolicy)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.appFont(weight: .bold, size: 12), range: privacyPolicyRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: finalPrivecyUrl, range: privacyPolicyRange)
        
        // You must set the formatting of the link manually
        let linkAttributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.black
        ]
        
        self.txtSub.attributedText = attributedOriginalText
        self.txtSub.delegate = self
        self.txtSub.isSelectable = true
        self.txtSub.isEditable = false
        self.txtSub.linkTextAttributes = linkAttributes
        self.txtSub.textAlignment = .center
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        // if (URL.absoluteString == "https://www.google.co.in/") {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL, options: [:])
        } else {
            UIApplication.shared.openURL(URL)
        }
        //}
        return false
    }
}

extension AppPurchasePacksVC {
    
    
    
    private func checkSubApi(orderId: String){
        print("\(TAG) checkSubApi() orderId \(orderId)")
        
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            let uniqeId = Util.getProfile()?.uniqueId ?? ""
            RequestManager.shared.checkSubscriptionWithOrderId(unique: uniqeId, orderId: orderId, onCompletion: { (response) in
                let checkSubModel = CheckSubscriptionResponse.init(json: response)
                if checkSubModel.status?.lowercased() == "success" {
                    let subscriptionObj = checkSubModel.subscription
                    if subscriptionObj?.statusStatus ?? false {
                        let alertView = AlertView()
                        alertView.delegate = self
                        alertView.showAlert(vc: self, title: "", message: checkSubModel.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 8)
                    }else {
                        let alertView = AlertView()
                        alertView.delegate = self
                        alertView.showAlert(vc: self, title: "", message: checkSubModel.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
                    }
                    checkSubModel.save()
                    
                }else {
                    let alertView = AlertView()
                    alertView.delegate = self
                    alertView.showAlert(vc: self, title: "", message: checkSubModel.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
                }
                Util.hideLoader()
                //print("\(self.TAG) Fyndr :checkSubscriptionResponse - \(response)")
            })
            { (error) in
                Util.hideLoader()
                print("DashboardViewController: checkSubscriptionRequest() - error: \(String(describing: error?.localizedDescription))")
                let alertView = AlertView()
                alertView.delegate = self
                alertView.showAlert(vc: self, title: "", message:  NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
            }
        }else {
            print("Fyndr :checkSubscriptionRequest - not connected to internet")
            let alertView = AlertView()
            alertView.delegate = self
            alertView.showAlert(vc: self, title: "", message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
        }
    }
    
    
    private func checkSubApi(){
        if Reachability.isInternetConnected()
        {
            let uniqeId = Util.getProfile()?.uniqueId ?? ""
            RequestManager.shared.checkSubscriptionWithOrderId(unique: uniqeId, orderId: "", onCompletion: { (response) in
                let checkSubModel = CheckSubscriptionResponse.init(json: response)
                if checkSubModel.status?.lowercased() == "success" {
                    checkSubModel.save()
                    self.navigationController?.popViewController(animated: true)
                }else {
                    let alertView = AlertView()
                    alertView.delegate = self
                    alertView.showAlert(vc: self, title: "", message: checkSubModel.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
                }
                Util.hideLoader()
                //print("\(self.TAG) Fyndr :checkSubscriptionResponse - \(response)")
            })
            { (error) in
                Util.hideLoader()
                print("DashboardViewController: checkSubscriptionRequest() - error: \(String(describing: error?.localizedDescription))")
                let alertView = AlertView()
                alertView.delegate = self
                alertView.showAlert(vc: self, title: "", message:  NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
            }
        }else {
            print("Fyndr :checkSubscriptionRequest - not connected to internet")
            let alertView = AlertView()
            alertView.delegate = self
            alertView.showAlert(vc: self, title: "", message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
        }
    }
}



extension AppPurchasePacksVC {
    private func sendOpenScreenEvent() {
        AppAnalytics.log(.openScreen(screen: .subscribe))
        TPAnalytics.log(.openScreen(screen: .subscribe))
    }
    
    private func sendOpenSettingScreenEvent() {
        AppAnalytics.log(.openScreen(screen: .wifi_setting))
        TPAnalytics.log(.openScreen(screen: .wifi_setting))
    }
    
    
    private func sendSubscriptionStatusEvent (packId: String, status: String) {
        AppAnalytics.log(.subscription(packId: packId, status: status))
        TPAnalytics.log(.subscription(packId: packId, status: status))
    }
    
    private func packSelectionEvent(packId: String) {
        AppAnalytics.log(.packSelection(packId: packId))
        TPAnalytics.log(.packSelection(packId: packId))
    }
}

enum  PackType : String {
    case storePack = "APPLE"
    case operatorPack = "OPERATOR"
}




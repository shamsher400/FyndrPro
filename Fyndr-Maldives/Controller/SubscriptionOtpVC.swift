//
//  SubscriptionOtpVC.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 10/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import SVPinView

class SubscriptionOtpVC: UIViewController {
    
    @IBOutlet weak var btnResendOtp: UIButton!
    @IBOutlet weak var viewOtpContainer: UIView!
    @IBOutlet weak var viewOtpText: SVPinView!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var bntCancel: UIButton!
    
    @IBOutlet weak var lblOtpMessage: UILabel!
    @IBOutlet weak var lblOtpTimer: UILabel!
    
    var timerCount = 60
    
    
    var subscriptionResponse : ((_ success: Bool, _ message: String) -> Void)?
    
    var orderId: String?
    
    let TAG = "SubscriptionOtpVC:: "
    
    var otpText = ""
    
    private var viewPreviousHeight = 0
    private var previousYPosition = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        viewOtpText.shouldSecureText = false
        viewOtpText.didFinishCallback = { pin in
            print("The pin entered is \(pin)")
            self.otpText = pin
            
            if pin.count != 4 {
                self.btnOk.alpha = 0.5
                self.btnOk.isEnabled = false
            }else {
                self.btnOk.alpha = 1
                self.btnOk.isEnabled = true
            }
        }
        
        viewOtpText.didChangeCallback = { pin in
            print("The pin entered did is \(pin)")
            self.otpText = pin
        }
        
        startTimer()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        if let userInfo = notification.userInfo
        {
            if var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            {
                keyboardFrame = self.view.convert(keyboardFrame, from: nil)
                print("keyboart height \(keyboardFrame.size.height)")
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification:NSNotification){
        print("keyboart hide")
        
    }
    @IBAction func btnResendOtp(_ sender: Any) {
        resentOtp(orderId: orderId ?? "" )
    }
    
    @IBAction func btnOk(_ sender: Any) {
        if let orderId = orderId , otpText.count == 4{
            submitOtpForPurchasePack(orderId: orderId, otp: otpText)
        }else {
            let alertView = AlertView()
            alertView.delegate = self
            alertView.showAlert(vc: self, title: "", message: NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
            print("\(self.TAG) error : wrong otp")
        }
    }
    private func resentOtp(orderId: String ) {
        Util.showLoader()
        RequestManager.shared.resentPurchaseOtp(orderId: orderId, onCompletion: { (responseJson) in
            DispatchQueue.main.async {
                let purchasePackModel = Response.init(json: responseJson)
                if purchasePackModel.status?.lowercased() == "success" {
                    self.timerCount = 60
                    Util.hideLoader()

                    self.startTimer()
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

    @IBAction func btnCancel(_ sender: Any) {
        subscriptionResponse!(false, "Cancle By User ")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func submitOtpForPurchasePack(orderId: String , otp: String) {
        Util.showLoader()
        RequestManager.shared.purchasePackWithOtp(orderId: orderId, otp: otp, onCompletion:  { (responseJson) in
            DispatchQueue.main.async {
                let purchasePackModel = PurchaseSubscriptionVerifyOtp.init(json: responseJson)
                if purchasePackModel.status?.lowercased() == "success" {
                    DispatchQueue.main.async {
                        self.subscriptionResponse!(true, purchasePackModel.reason ?? "Purchase success")
                        Util.hideLoader()
                        self.dismiss(animated: true, completion: nil)
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
            alertView.showAlert(vc: self, title: "", message: NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
            print("\(self.TAG) error : \(String(describing: error?.localizedDescription))")
        })
    }
    
}

// Otp resent timer
extension SubscriptionOtpVC {
    
    private func startTimer(){
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        timerCount = timerCount - 1
        if(timerCount > 0) {
            lblOtpTimer.isHidden = false
            btnResendOtp.isHidden = true
            lblOtpTimer.text = NSLocalizedString("Wait : ", comment: "") + String(timerCount)
        }else {
            lblOtpTimer.isHidden = true
            btnResendOtp.isHidden = false
            
        }
    }
}


extension SubscriptionOtpVC: AlertViewDelegate {
    func okButtonAction(tag: Int) {
        if tag == 0 {
            subscriptionResponse!(false, NSLocalizedString("M_GENERIC_ERROR", comment: ""))
        }
    }
    
    func cancelButtonAction(tag: Int) {
        
    }
    
    
}

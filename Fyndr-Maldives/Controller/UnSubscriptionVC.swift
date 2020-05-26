//
//  UnSubscriptionVC.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 12/11/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class UnSubscriptionVC: UIViewController {

    @IBOutlet weak var btnUnsubscribe: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblUnsubscribeText: UILabel!
    
    @IBOutlet weak var imgUnsubscribe: UIImageView!
    private var userUnsubscribed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("unsubscribe ...........")
        
        self.title = NSLocalizedString("M_UN_SUBSCRIBE", comment: "")
        lblUnsubscribeText.text = NSLocalizedString("M_UN_SUBSCRIBE_CONTENT", comment: "")
        btnCancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        btnUnsubscribe.setTitle(NSLocalizedString("M_UN_SUBSCRIBE", comment: ""), for: .normal)


        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    @IBAction func btnUnsubscribe(_ sender: Any) {
        
        if userUnsubscribed {
            self.navigationController?.popViewController(animated: true)
        }else {
            unSubscribePacks()
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func packUnsubscribedUpdateUi(){
        btnCancel.isHidden = true
        btnUnsubscribe.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
        lblUnsubscribeText.isHidden = true
        userUnsubscribed = true
        imgUnsubscribe.isHidden = false
    }
    
    
    private func unSubscribePacks()
    {
        if Reachability.isInternetConnected()
        {
            RequestManager.shared.unsubscribePack( onCompletion: { (responseJson) in
                let response = Response.init(json: responseJson)
                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    if response.status != nil && response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue {
                        self.packUnsubscribedUpdateUi()
                    }else {
                        self.showSystemError(message: response.reason ?? NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
                    }
                  
                }
            }) { (error) in
                print("error : \(String(describing: error?.localizedDescription))")
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    self.showSystemError(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
                }
            }
        }else{
            self.showSystemError(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }

}
extension UnSubscriptionVC: AlertViewDelegate {
    
    private func showSystemError(message : String)
    {
        AlertView().showAlert(vc: self, title: "", message: message, okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
    }
    func okButtonAction(tag: Int) {
        if tag == 1 {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func cancelButtonAction(tag: Int) {
        
    }
}


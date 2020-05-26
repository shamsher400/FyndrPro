//
//  SubscriptionAleartVC.swift
//  Fyndr-MMR
///Users/shamshersingh/Desktop/IOS Projects/ttIbadat/3ibadat/IslamicPortal/IslamicPortal-Info.plist
//  Created by Shamsher Singh on 01/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class SubscriptionAleartVC: UIViewController {
    @IBOutlet weak var lblAlertTitle: UILabel!
    @IBOutlet weak var lblAlertDescriptions: UILabel!
    
    @IBOutlet weak var lblBottomViewDesc: UILabel!
    @IBOutlet weak var lblBottomViewTitle: UILabel!
    var openSubscriptionPage : (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lblAlertTitle.text = NSLocalizedString("M_SUBSCRIPTION_ALERT_TITLE", comment: "")
        lblAlertDescriptions.text = NSLocalizedString("M_SUBSCRIPTION_ALERT_DEC", comment: "")
        
        lblBottomViewTitle.text = NSLocalizedString("M_BUY_VIP_PASS", comment: "")
        lblBottomViewDesc.text = NSLocalizedString("M_SUBSCRIPTION_BOOTOM_DEC", comment: "")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        sendOpenScreenEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    @IBAction func btnOpenSubscriptions(_ sender: Any) {
        guard let openSubscriptionPage =  openSubscriptionPage else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        self.dismiss(animated: false, completion: {
            openSubscriptionPage()
        })
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SubscriptionAleartVC {
    private func sendOpenScreenEvent() {
        AppAnalytics.log(.openScreen(screen: .subscribe_alert))
        TPAnalytics.log(.openScreen(screen: .subscribe_alert))
    }
}

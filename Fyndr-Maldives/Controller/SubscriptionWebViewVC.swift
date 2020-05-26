//
//  SubscriptionWebViewVC.swift
//  Fyndr-LKA
//
//  Created by Shamsher Singh on 11/12/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class SubscriptionWebViewVC: UIViewController, UIWebViewDelegate {
    
    let TAG = "SubscriptionWebViewVC :: "
    
    @IBOutlet weak var webViewSubscription: UIWebView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var transactionUrl = ""
    var subscriptionId = ""
    var packId = ""
    
    var subscriptionResponse : ((_ success: Bool) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewSubscription.delegate = self
        if let url = URL(string: transactionUrl) {
            let requestUrl = URLRequest(url: url as URL)
            webViewSubscription.loadRequest(requestUrl)
        }else {
            transactionFailedAction()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showLoader()
    }
    
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print( "\(TAG) webView -  didFailLoadWithError() loadUrl \(String(describing: webView.request?.url?.absoluteString))  Error \(error.localizedDescription)")
        transactionFailedAction()
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print( "\(TAG) webView -  webViewDidFinishLoad() loadUrl \(String(describing: webView.request?.url?.absoluteString)) ")
        let urlInStr = webView.request?.url?.absoluteString
        if (urlInStr?.contains("MCCPortal/service/processForm")) ?? false {
            transactionSuccessAction()
        }
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print( "\(TAG) webView -  shouldStartLoadWith() loadUrl \(String(describing: webView.request?.url?.absoluteString)) ")
    }
    
    
    private func transactionFailedAction() {
        Util.hideLoader()
        self.navigationController?.popViewController(animated: false)
        subscriptionResponse!(false)
    }
    
    
    private func transactionSuccessAction() {
        Util.hideLoader()
        self.navigationController?.popViewController(animated: false)
        subscriptionResponse!(true)
        
    }
    
    
    private func showLoader() {
        if !indicatorView.isAnimating {
            indicatorView.startAnimating()
            indicatorView.isHidden = false
        }
    }
    
    private func hideLoader() {
        if indicatorView.isAnimating {
            indicatorView.stopAnimating()
            indicatorView.isHidden = true
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
    
}

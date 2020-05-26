//
//  WebViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var url : String?
    var titleText : String?
    var openTag : String?
    var presented : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleText
        openWebPage()
        
        if self.presented
        {
            self.setupNavbar()
        }
        
        if let tag = openTag {
            if tag == "tag_faq" {
                setupNavbarForTNC()
            }
        }
    }
    
    fileprivate func openWebPage()
    {
        if Reachability.isInternetConnected()
        {
            guard let pageUrl = url, let finalUrl = URL (string: pageUrl + "?lang=\(Util.getPhoneLang())") else {
                return
            }
            let request = URLRequest(url:finalUrl)
            webview.delegate = self
            webview.loadRequest(request)
            self.loader.isHidden = false
            self.loader.startAnimating()
        }else {
            let alertView = AlertView.init()
            alertView.delegate = self
            alertView.showAlert(vc: self, message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    fileprivate func setupNavbar()
    {
        let backBtn = UIButton.init(type: .custom)
        backBtn.setImage(UIImage(named: "back-ios"), for: .normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 30)
        backBtn.backgroundColor = UIColor.clear
        backBtn.addTarget(self, action: #selector(dismissView), for: UIControl.Event.touchUpInside)
        backBtn.contentHorizontalAlignment = .left
        backBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -8, bottom: 0, right: 0)
        let backBarButton = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    
    fileprivate func setupNavbarForTNC()
    {
        let backBtn = UIButton.init(type: .custom)
        backBtn.setTitle(NSLocalizedString("T&C", comment: ""), for: .normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 30)
        backBtn.backgroundColor = UIColor.clear
        backBtn.addTarget(self, action: #selector(openTnCPage), for: UIControl.Event.touchUpInside)
        backBtn.contentHorizontalAlignment = .left
        backBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -8, bottom: 0, right: 0)
        let backBarButton = UIBarButtonItem(customView: backBtn)
        self.navigationItem.rightBarButtonItem = backBarButton
    }
    
    @objc func openTnCPage()
    {
        openWebView(url: TERM_OC_CONDITIONS_URL, titleText: NSLocalizedString("M_TERM_AND_CONDITIONS", comment: "")
)
    }
    
    @objc func dismissView()
    {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    
    fileprivate func openWebView(url : String, titleText : String)
    {
        var redirectUrl = url + "?userId="
        let webVC = UIStoryboard.getViewController(identifier: "WebViewController") as!  WebViewController
        if let userId = Util.getProfile()?.uniqueId {
            redirectUrl = redirectUrl + userId
        }
        webVC.url = redirectUrl
        webVC.titleText = titleText
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
}

extension WebViewController : UIWebViewDelegate
{
    //MARK:- UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad URL : ",webView.request?.url ?? "")

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad URL : ",webView.request?.url ?? "")

        self.loader.stopAnimating()
        self.loader.isHidden = true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.loader.stopAnimating()
        self.loader.isHidden = true
        print("Webview error : ",error.localizedDescription )
    }
    
    private func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let requestString = request.url?.absoluteString
        print("Request URL : ",requestString ?? "")
        return true
    }

    fileprivate func dismissViewController()
    {
        guard let _ = navigationController?.popViewController(animated: true) else
        {
                print("Not a navigation Controller")
                dismiss(animated: true, completion: nil)
                return
        }
    }
}

extension WebViewController : AlertViewDelegate {
    func cancelButtonAction(tag: Int) {
        
    }
    
    func okButtonAction(tag : Int)
    {
        dismissViewController()
    }
    
}

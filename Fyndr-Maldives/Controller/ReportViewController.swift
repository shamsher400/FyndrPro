//
//  ReportViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 23/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import DropDown

class ReportViewController: UIViewController {
    
    @IBOutlet weak var reasonView : UIView!
    @IBOutlet weak var reasonTitleLbl : UILabel!
    @IBOutlet weak var reasonTxt : UITextField!
    @IBOutlet weak var submitButton : UIButton!
    @IBOutlet weak var commentTxtView : UITextView!
    
    fileprivate var reportReasons : [Reason]?
    var profile: Profile?
    var chatHistory : ChatHistory?
    var uniqueId : String?
    let reasonDropDown = DropDown()
    var seletedReportReasons : Reason? = nil

    var commentPlaceHolder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTxtView.text = commentPlaceHolder
        commentTxtView.textColor = UIColor.lightGray
        commentTxtView.delegate = self
        
        commentPlaceHolder = NSLocalizedString("M_ADDITIONAL_INFO", comment: "")
        
        
        if let profile = profile
        {
            uniqueId = profile.uniqueId
            self.title = profile.name
        }else if let chatHistory = chatHistory
        {
            uniqueId = chatHistory.uniqueId
            self.title = chatHistory.name
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        reportReasons = Util.getReportReasons()
        if reportReasons !=  nil && (reportReasons?.count)! > 0
        {
            setupView()
            self.getReportReasons(blocking: false)
        }else{
            self.getReportReasons(blocking: true)
        }
        reasonTitleLbl.font = UIFont.autoScale(weight: .regular, size: 15)
         reasonTitleLbl.text = NSLocalizedString("M_PLEASE_LET_US_KNOW_WHY_DO_YOU_WANT_REPORT", comment: "")
        reasonTxt.font = UIFont.autoScale(weight: .regular, size: 17)
        reasonTxt.placeholder = NSLocalizedString("M_SELECT_A_REASON", comment: "")
        
        submitButton.titleLabel?.font = UIFont.autoScale(weight: .semibold, size: 17)
        
        submitButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .report))
        TPAnalytics.log(.openScreen(screen: .report))
    }
    
    override func viewWillLayoutSubviews() {
        submitButton.setGradient(colors: defaultGradientColors)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    fileprivate func setupView()
    {
        guard let reportReasons = reportReasons else {
            return
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectReason))
        self.reasonView.addGestureRecognizer(tapGesture)
        
        reasonDropDown.anchorView = self.reasonView
        reasonDropDown.width = SCREEN_WIDTH * 0.8
        reasonDropDown.bottomOffset = CGPoint(x: 0, y: 40)
        reasonDropDown.dataSource = reportReasons.map({$0.reason ?? ""})
        reasonDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            cell.optionLabel.text = item
        }
        // Action triggered on selection
        reasonDropDown.selectionAction = { [unowned self] (index, item) in
            print("Selected item: \(item) at index: \(index)")
            let reason = reportReasons[index]
            self.reasonTxt.text = item
            self.seletedReportReasons = reason
        }
    }
    
    
    @objc func selectReason()
    {
        reasonDropDown.show()
    }
    
    fileprivate func getReportReasons(blocking : Bool){
        
        if blocking {
            if !Reachability.isInternetConnected()
            {
                let alertView = AlertView.init()
                alertView.delegate = self
                alertView.showAlert(vc: self, message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
                return
            }
            Util.showLoader()
        }
        
        RequestManager.shared.reportProfileResoneRequest(onCompletion: { (responseJson) in
            DispatchQueue.main.async {
                
                Util.hideLoader()
                let response =  ReportReasons.init(json: responseJson)
                if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                {
                    if let reasons = response.reasons
                    {
                        Util.saveReportReasons(reportReasons: response)
                        
                        if blocking {
                            self.reportReasons = reasons
                            self.setupView()
                        }
                    }
                }else {
                    if blocking {
                        let alertView = AlertView.init()
                        alertView.delegate = self
                        alertView.showAlert(vc: self, message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                if blocking {
                    Util.hideLoader()
                    let alertView = AlertView.init()
                    alertView.delegate = self
                    alertView.showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                }
            }
        }
    }
    
    @IBAction func loginButtonAction(_ sender : UIButton)
    {
        self.view.endEditing(true)
        self.validateData()
    }
    
    
    fileprivate func reportProfile(comment : String)
    {
        guard let uniqueId = uniqueId else {
            return
        }
        
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            RequestManager.shared.reportProfileRequest(reportedId: uniqueId, reasonId : seletedReportReasons?.id ?? "", reason : seletedReportReasons?.reason ?? "", comments: comment, onCompletion: { (responseJson) in
                DispatchQueue.main.async {
                    
                    Util.hideLoader()
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        let alertView = AlertView.init()
                        alertView.delegate = self
                        alertView.showAlert(vc: self, message: response.reason ?? NSLocalizedString("M_REQUEST_SUCCESS", comment: ""))
                    }else {
                        AlertView().showAlert(vc: self, message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    Util.hideLoader()
                    AlertView().showNotficationMessage(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                }
            }
        }else{
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
        
    }
    
    
    fileprivate func validateData()
    {
        guard uniqueId != nil else {
            return
        }
        if seletedReportReasons != nil {
            
            var comment = ""
            if self.commentTxtView.text != commentPlaceHolder
            {
                comment = self.commentTxtView.text?.trimmingCharacters(in: .whitespaces) ?? ""
            }
            reportProfile(comment: comment)
            submiteReportOnAnalytics(uniqId: uniqueId, reasonId: seletedReportReasons?.id)
        }else{
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INVALID_REASON", comment: ""))
        }
    }
    
    private func submiteReportOnAnalytics(uniqId: String?, reasonId: String?) {
       
        if let uniqeId = uniqId, let reasonId = reasonId {
            AppAnalytics.log(.reportPorfile(uniqueid: uniqeId, reasonId: reasonId))
            TPAnalytics.log(.reportPorfile(uniqueid: uniqeId, reasonId: reasonId))
        }
    }
}

extension ReportViewController : UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = commentPlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }
    
}

extension ReportViewController : AlertViewDelegate {
    func cancelButtonAction(tag: Int) {
        
    }
    
    func okButtonAction(tag : Int)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
}

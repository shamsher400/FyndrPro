//
//  ChangeLanguageVC.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 25/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class ChangeLanguageVC: UIViewController{
    
    @IBOutlet weak var lblChangeLanguageTitle: UILabel!
    @IBOutlet weak var lblChangeLanguageDes: UILabel!
    @IBOutlet weak var tblLanguages: UITableView!
    
    var languages: [Language] = [.dhivehi,.english(.us)]
    var currentLanguage = Bundle.getCurrentLanguage()
    var selectedLanguage = Bundle.getCurrentLanguage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("M_CHANGE_LANGUAGE", comment: "")
        tblLanguages.delegate = self
        tblLanguages.dataSource = self
        tblLanguages.tintColor = UIColor.appPrimaryBlueColor
        self.tblLanguages.tableFooterView = UIView()
        
        lblChangeLanguageTitle.text = NSLocalizedString("M_PREFERED_LANGUAGE", comment: "")
        lblChangeLanguageDes.text = NSLocalizedString("M_SELECT_LANGUAGE", comment: "")
    }
    
    private func enableDisableSaveButton() {

        if currentLanguage != selectedLanguage {
            let menuBtn = UIButton.init()
            menuBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
            menuBtn.setTitleColor(.blue, for: .normal)
            menuBtn.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
            let rightButton = UIBarButtonItem(customView: menuBtn)
            navigationItem.rightBarButtonItem = rightButton
        }else {
            self.navigationItem.rightBarButtonItem = nil
        }
        tblLanguages.reloadData()
    }
    

    fileprivate func updateLanguageAndReload()
    {
        // To set localization
        Bundle.set(language: selectedLanguage)
//        APP_DELEGATE.openScreen(screenName: .dashboard, firstScreen: true)
        APP_DELEGATE.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
    }
    
    @objc func pressButton(button: UIButton) {
        print("Left bar button item")
        notifyServerForChangeLanguage()
    }
    
    fileprivate func notifyServerForChangeLanguage()
    {
        if Reachability.isInternetConnected()
        {
            RequestManager.shared.appConfigurationChangeLanguageRequest(configurationType : .basic, languageCode: selectedLanguage.langCodeOnServer, onCompletion: { (responseJson) in

                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        self.updateLanguageAndReload()
                    }
                    else {
                        let alertView = AlertView()
                        alertView.delegate = self
                        alertView.showAlert(vc: self, title: "", message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
                    }
                }
            }) { (error) in
                print("error : \(String(describing: error?.localizedDescription))")
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    let alertView = AlertView()
                    alertView.delegate = self
                    alertView.showAlert(vc: self, title: "", message: NSLocalizedString("M_GENERIC_ERROR", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 1)
                }
            }
        }else{
            self.showSystemError(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
}

extension ChangeLanguageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "languageTable")
        cell.textLabel?.text = languages[indexPath.row].name
        cell.imageView?.image = UIImage.init(named: languages[indexPath.row].imageName)
        
        if selectedLanguage == languages[indexPath.row] {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .changeLanguageSelected
        }else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .gray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.selectedLanguage = languages[indexPath.row]
            self.enableDisableSaveButton()
    }
}


extension ChangeLanguageVC: AlertViewDelegate {
    
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

extension ChangeLanguageVC {
    
    private func openScreenEvent() {
        AppAnalytics.log(.openScreen(screen: .language))
        TPAnalytics.log(.openScreen(screen: .language))

    }
}

//
//  SettingViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 17/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit


enum NavigationInApp : String {
    case logout = "logout"
    case mute = "mute"
    case visibility = "visibility"
    case blockList = "block_lits"
    case localisation = "localisation"
    case deleteAccount = "delete_account"
    case unsubscribe = "unsubscribe"

}

struct Setting  {
    var title : String
    var menuItems : [MenuItem]
}

class SettingViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var sections = [Setting]()
    let cellIdentifier = "cellIdentifier"
    var myProfile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Settings", comment: "")
        myProfile = Util.getProfile()
        // Do any additional setup after loading the view.
        initDataSource()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        //self.tableView.tableHeaderView = hearerView()
        self.tableView.tableFooterView = UIView()
        setupNavbar()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .setting))
        TPAnalytics.log(.openScreen(screen: .setting))
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
    
    @objc func dismissView()
    {
        self.dismiss(animated: true, completion: nil)
    }
}


extension SettingViewController : UITableViewDelegate, UITableViewDataSource
{
    
    func initDataSource()
    {
        

        let block = MenuItem.init(menuTitle: NSLocalizedString("M_BLOCK_LIST", comment: ""),menuThumb :"blocked-list-icon", menuAction: .app, menuUrl: NavigationInApp.blockList.rawValue,tag : "")
        let mute = MenuItem.init(menuTitle: NSLocalizedString("M_DO_NOT_DISTURB", comment: ""),menuThumb :"mute-icon", menuAction: .app, menuUrl: NavigationInApp.mute.rawValue,tag : "")
        let connections = Setting(title: NSLocalizedString("M_CONNECTIONS", comment: ""), menuItems: [block,mute])
        sections.append(connections)
        
        let language = MenuItem.init(menuTitle: NSLocalizedString("M_CHANGE_LANGUAGE", comment: ""),menuThumb :"language_settings", menuAction: .app, menuUrl: NavigationInApp.localisation.rawValue,tag : "")

        let localizations = Setting(title: NSLocalizedString("M_LOCALIZATIONS", comment: ""), menuItems: [language])
        sections.append(localizations)
        

        let logout = MenuItem.init(menuTitle: NSLocalizedString("Logout", comment: ""),menuThumb :"logout-icon", menuAction: .app, menuUrl: NavigationInApp.logout.rawValue,tag : "")
        let visibility = MenuItem.init(menuTitle: NSLocalizedString("Visibility", comment: ""),menuThumb :"visiblity-icon", menuAction: .app, menuUrl: NavigationInApp.visibility.rawValue,tag : "")
        
        //let deleteAccount = MenuItem.init(menuTitle: "Delete Account",menuThumb :"close-account-icon", menuAction: .app, menuUrl: NavigationInApp.deleteAccount.rawValue)
        // let account = Setting(title: "Account", menuItems: [logout,visibility,deleteAccount])
        let account = Setting(title: NSLocalizedString("Account", comment: ""), menuItems: [logout,visibility])
        sections.append(account)
        
        let feedbackOpt = MenuItem.init(menuTitle: NSLocalizedString("Feedback", comment: ""),menuThumb :"help-icon", menuAction: .html, menuUrl: FEEDBCK_URL,tag : "")

        let faq = MenuItem.init(menuTitle: NSLocalizedString("Faq", comment: "") ,menuThumb :"info-icon", menuAction: .html, menuUrl: FAQ_URL,tag : "tag_faq")
        
        let support = Setting(title: NSLocalizedString("Support", comment: "") , menuItems: [faq, feedbackOpt])
        sections.append(support)
        
        
        
        if Util.getSubscribeValidityIsAvalibale() && Util.getMsisdn() != "" {
            let unsubscribe = MenuItem.init(menuTitle: NSLocalizedString("M_UN_SUBSCRIBE", comment: "") ,menuThumb :"info-icon", menuAction: .app, menuUrl: NavigationInApp.unsubscribe.rawValue,tag : "unsubscribe")
            
            let support = Setting(title: NSLocalizedString("M_SERVICE", comment: "") , menuItems: [unsubscribe])
            sections.append(support)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let sectionHeader = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        sectionHeader.backgroundColor = UIColor.clear
        
//        if section != 0
//        {
            let lable = UILabel.init(frame: CGRect(x: 15, y: 0, width: sectionHeader.bounds.width, height: sectionHeader.bounds.height))
            lable.font = UIFont.autoScale(weight: .medium, size: 15)
            lable.text = sections[section].title
            lable.textColor = UIColor.gray
            
            if section == 2 {
                if let userNumber = myProfile?.contactNumber {
                    let lable = UILabel.init(frame: CGRect(x: (sectionHeader.bounds.width / 2) - 15 , y: 0, width: sectionHeader.bounds.width / 2, height: sectionHeader.bounds.height))
                    lable.font = UIFont.autoScale(weight: .medium, size: 15)
                    lable.text = userNumber
                    lable.textColor = UIColor.gray
                    lable.textAlignment = .right
                    lable.minimumScaleFactor = 0.5
                    sectionHeader.addSubview(lable)
                    
                }
            }
            
            sectionHeader.addSubview(lable)
//        }
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_HEIGHT/10 > 60 ? 60 : SCREEN_HEIGHT/10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style:.default, reuseIdentifier: cellIdentifier)
        cell.backgroundColor = UIColor.white
        cell.textLabel?.textColor = UIColor.black
        cell.selectionStyle = .none
        cell.accessoryType = .none
        
        let menuItems = sections[indexPath.section].menuItems
        let menuItem = menuItems[indexPath.row]
        
        cell.textLabel?.font = UIFont.autoScale(weight: .regular, size: 17)
        cell.textLabel?.text = menuItem.menuTitle
        cell.imageView?.image = UIImage.init(named: menuItem.menuThumb)
        
        if menuItem.menuAction == .app && menuItem.menuUrl == NavigationInApp.mute.rawValue
        {
            let switchView = UISwitch(frame: .zero)
            switchView.addTarget(self, action: #selector(muteSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            switchView.setOn(myProfile?.isMute ?? false, animated: false)
            
        }else if menuItem.menuAction == .app && menuItem.menuUrl == NavigationInApp.visibility.rawValue
        {
            let switchView = UISwitch(frame: .zero)
            switchView.addTarget(self, action: #selector(visibilitySwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            switchView.setOn(myProfile?.isVisible ?? false, animated: false)
        } else{
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItems = sections[indexPath.section].menuItems
        let menuItem = menuItems[indexPath.row]
        openScreenFromMenu(menu: menuItem)
    }
    
    
    @objc func muteSwitchChanged(_ sender : UISwitch!){
        if sender.isOn
        {
            print("Mute profile")
            self.updateSettingOnServer(mute: true, isVisible: nil, switchView: sender)
            sendDndActionToAnalytics(action: "true")
        }else {
            print("unMute profile")
            self.updateSettingOnServer(mute: false, isVisible: nil, switchView: sender)
            sendDndActionToAnalytics(action: "false")

        }
    }
    
    
    @objc func visibilitySwitchChanged(_ sender : UISwitch!){
        
        if sender.isOn
        {
            print("Visible profile")
            self.updateSettingOnServer(mute: nil, isVisible: true, switchView: sender)
            sendVisibilityActionToAnalytics(action: "true")
        }else {
            print("InVisible profile")
            self.updateSettingOnServer(mute: nil, isVisible: false, switchView: sender)
            sendVisibilityActionToAnalytics(action: "false")

        }
    }
    
    fileprivate func openScreenFromMenu(menu : MenuItem)
    {
        switch menu.menuAction {
        case .app:
            
            switch menu.menuUrl {
            case NavigationInApp.blockList.rawValue :
                let blockListViewController = UIStoryboard.getViewController(identifier: "BlockListViewController") as!  BlockListViewController
                self.navigationController?.pushViewController(blockListViewController, animated: true)
                break
            case NavigationInApp.logout.rawValue :
                self.showLogoutAlert(delete : false)
                break
            case NavigationInApp.deleteAccount.rawValue :
                self.showLogoutAlert(delete : true)
                break
                
            case NavigationInApp.localisation.rawValue :
                let blockListViewController = UIStoryboard.getViewController(identifier: "ChangeLanguageVC") as!  ChangeLanguageVC
                self.navigationController?.pushViewController(blockListViewController, animated: true)
                break
            case NavigationInApp.unsubscribe.rawValue :
                let blockListViewController = UIStoryboard.getViewController(identifier: "UnSubscriptionVC") as!  UnSubscriptionVC
                self.navigationController?.pushViewController(blockListViewController, animated: true)
                break
            default:
                break
            }
            break
        case .html:
            if menu.menuUrl.count > 0
            {
                if menu.tag == "tag_help" {
                    openHelpScreenEvent()
                }else if menu.tag == "tag_faq" {
                    openFaqScreenEvent()
                }
                openWebView(url: menu.menuUrl, titleText: menu.menuTitle, openTag: menu.tag)
            }
        }
    }
    
    fileprivate func showLogoutAlert(delete : Bool)
    {
        AppAnalyticsEngine.init().uploadEventOnServer()
        BookmarkManager.shared.updateBookmarkOnServer()
        
        var message = NSLocalizedString("M_LOGOUT", comment: "")
        if delete
        {
            message = NSLocalizedString("M_DELETE_ACCOUNT", comment: "")
        }
        // Create the alert controller
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("M_CANCEL", comment: ""), style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default) {
            UIAlertAction in
            
            if delete {
                self.deleteAccountFromServer()
            }else{
                APP_DELEGATE.logout()
                APP_DELEGATE.openScreen(screenName: .intro , firstScreen: true)
            }
        }
        alertController.addAction(okAction)
        
        
        alertController.modalPresentationStyle = .fullScreen
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    fileprivate func openWebView(url : String, titleText : String, openTag : String)
    {
        let webVC = UIStoryboard.getViewController(identifier: "WebViewController") as!  WebViewController
        webVC.url = "\(url)?userId=\(myProfile?.uniqueId ?? "")"
        webVC.titleText = titleText
        webVC.openTag = openTag
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    fileprivate func deleteAccountFromServer()
    {
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            
            RequestManager.shared.deleteAccountRequest(onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        APP_DELEGATE.logout()
                        APP_DELEGATE.openScreen(screenName: .registartion , firstScreen: true)
                        
                    }else{
                        AlertView().showAlert(vc: self, message:response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    Util.hideLoader()
                    AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                }
            }
            
        }else{
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    
    fileprivate func updateSettingOnServer(mute : Bool? , isVisible : Bool?, switchView : UISwitch)
    {
        guard let profile = self.myProfile else {
            return
        }
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            
            RequestManager.shared.settingRequest(isMute : mute ?? profile.isMute, isVisible : isVisible ?? profile.isVisible, onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        self.myProfile?.isMute = mute ?? profile.isMute
                        self.myProfile?.isVisible = isVisible ?? profile.isVisible
                        Util.saveProfile(myProfile: self.myProfile)
                        AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_REQUEST_SUCCESS", comment: ""))
                    }else{
                        switchView.setOn(!switchView.isOn, animated: false)
                        AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    switchView.setOn(!switchView.isOn, animated: false)
                    Util.hideLoader()
                    AlertView().showNotficationMessage(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                }
            }
        }else {
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
            switchView.setOn(!switchView.isOn, animated: false)
        }
    }
}

extension SettingViewController {
    
    func sendVisibilityActionToAnalytics(action: String){
        AppAnalytics.log(.visibility(action: action))
        TPAnalytics.log(.visibility(action: action))

    }
    
    func sendDndActionToAnalytics(action: String){
        AppAnalytics.log(.dnd(action: action))
        TPAnalytics.log(.dnd(action: action))
    }
    
    func openHelpScreenEvent(){
        AppAnalytics.log(.openScreen(screen: .help))
        TPAnalytics.log(.openScreen(screen: .help))
    }
    
    func openFaqScreenEvent(){
        AppAnalytics.log(.openScreen(screen: .faq))
        TPAnalytics.log(.openScreen(screen: .help))
    }
    
}



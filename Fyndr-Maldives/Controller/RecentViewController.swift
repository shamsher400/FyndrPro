//
//  RecentViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import MessageKit

class RecentViewController: UIViewController {
    
    @IBOutlet weak var recentLbl : UILabel!
    @IBOutlet weak var dividerView : UIView!
    @IBOutlet weak var messageLbl : UILabel!
    
    @IBOutlet weak var noDataFoundView : UIView!
    @IBOutlet weak var noDataFoundTitleLbl : UILabel!
    @IBOutlet weak var noDataFoundDescLbl : UILabel!
    
    @IBOutlet weak var topMarginLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var unReadViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var recentCollectionView : UICollectionView!
    @IBOutlet weak var unreadCollectionView : UICollectionView!
    
    let recentCellIdentifier = "RecentCollectionViewCell"
    let unreadCellIdentifier = "RecentUnReadCollectionViewCell"
    
    var recentChatList : [ChatHistory]?
    var newChatList : [ChatHistory]?
    var myProfile: Profile?
    var topMargin = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Chat & Notifications", comment: "")
        
        self.recentLbl.isHidden = true
        self.dividerView.isHidden = true
        self.messageLbl.isHidden = true
        self.noDataFoundView.isHidden = true
        self.view.bringSubviewToFront(noDataFoundView)
        
        self.noDataFoundTitleLbl.font = UIFont.autoScale(weight: .medium, size: 19)
        self.noDataFoundDescLbl.font = UIFont.autoScale(weight: .medium, size: 15)
        self.recentLbl.font = UIFont.autoScale(weight: .semibold, size: 15)
        self.messageLbl.font = UIFont.autoScale(weight: .semibold, size: 15)
        
        
        self.noDataFoundTitleLbl.text = NSLocalizedString("M_BOOKMARK_NO_DATA_FOUND", comment: "")
        self.noDataFoundDescLbl.text = NSLocalizedString("M_RECENT_NOT_FOUND", comment: "")
        
        recentLbl.text = NSLocalizedString("Recent", comment: "")
        messageLbl.text = NSLocalizedString("Message", comment: "")
        
        checkAndLoadData()
        
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .recent))
        TPAnalytics.log(.openScreen(screen: .recent))
        myProfile = Util.getProfile()
        refreshDataInView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("Register Chat delegate : RVC")
        if ChatManager.share.isReady {
            ChatManager.share.addDelegate(delegate: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("DeRegister Chat delegate : RVC")
        if ChatManager.share.isReady {
            ChatManager.share.addDelegate(delegate: nil)
        }
    }
    
    deinit {
        //print("DeRegister Chat delegate : RVC")
        // ChatManager.share.addDelegate(delegate: nil)
    }
    
    fileprivate func refreshDataInView()
    {

        self.recentChatList = DatabaseManager.shared.getChatHistoryList(for: ConnectionStatus.connected.rawValue)
        self.newChatList = DatabaseManager.shared.getChatHistoryList(for: ConnectionStatus.new.rawValue)
        
        if let recentChatList = self.recentChatList, let newChatList = self.newChatList
        {
            self.showHideViewForData(recentChatCount: recentChatList.count, newChatCount: newChatList.count)
            
        }else if let recentChatList = self.recentChatList {
            self.showHideViewForData(recentChatCount: recentChatList.count, newChatCount: 0)
            
        }else if let newChatList = self.newChatList {
            self.showHideViewForData(recentChatCount: 0, newChatCount: newChatList.count)
        }else{
            print("new data not found here")
            self.showHideViewForData(recentChatCount: 0, newChatCount: 0)
        }
    }
    
    fileprivate func showHideViewForData(recentChatCount : Int, newChatCount : Int )
    {
        if recentChatCount == 0 && newChatCount == 0 {
            
            topMarginLayoutConstraint.constant = 0
            self.noDataFoundView.isHidden = false
            self.recentLbl.isHidden = true
            self.dividerView.isHidden = true
            self.messageLbl.isHidden = true
        }else {
            self.noDataFoundView.isHidden = true
            self.recentLbl.isHidden = false
            self.dividerView.isHidden = false
            self.messageLbl.isHidden = false
            topMarginLayoutConstraint.constant = topMargin
            
            recentCollectionView.reloadData()
            unreadCollectionView.reloadData()
        }
    }
    
    /*
     fileprivate func showHideViewForData(recentChatCount : Int, newChatCount : Int )
     {
     if recentChatCount > 0 && newChatCount > 0 {
     self.noDataFoundView.isHidden = true
     self.recentLbl.isHidden = false
     self.dividerView.isHidden = false
     self.messageLbl.isHidden = false
     topMarginLayoutConstraint.constant = topMargin
     
     recentCollectionView.reloadData()
     unreadCollectionView.reloadData()
     
     }else  if recentChatCount == 0 && newChatCount == 0 {
     
     topMarginLayoutConstraint.constant = 0
     self.noDataFoundView.isHidden = false
     self.recentLbl.isHidden = true
     self.dividerView.isHidden = true
     self.messageLbl.isHidden = true
     
     
     }else if recentChatCount > 0 {
     
     topMarginLayoutConstraint.constant = 0
     self.noDataFoundView.isHidden = true
     self.recentLbl.isHidden = true
     self.dividerView.isHidden = true
     self.messageLbl.isHidden = false
     recentCollectionView.reloadData()
     
     }else if newChatCount > 0 {
     
     topMarginLayoutConstraint.constant = 0
     self.noDataFoundView.isHidden = true
     self.recentLbl.isHidden = false
     self.dividerView.isHidden = true
     self.messageLbl.isHidden = true
     unreadCollectionView.reloadData()
     }
     }
     */
    
    
    
    public func openChatViewController(chatHistory : ChatHistory?)
    {
        guard let myProfile = self.myProfile else {
            return
        }
        if ChatManager.share.isReady {
            let chatVC = UIStoryboard.getViewController(identifier: "ChatViewController") as! ChatViewController
            chatVC.myProfile = myProfile
            chatVC.chatHistory = chatHistory
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    fileprivate func openUserProfileViewController(chatHistory : ChatHistory?)
    {
        guard let chatHistory = chatHistory else {
            return
        }
        let userDetailViewController = UIStoryboard.getViewController(identifier: "UserDetailViewController") as! UserDetailViewController
        userDetailViewController.chatHistory = chatHistory
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
    }
}


extension RecentViewController : ChatManagerDelegate
{
    func didSendMessage() {
        
    }

    func didFailedMessage(mxppMessage: String, error: Error) {
        print("failed chat send ")
    }

    func didReceiveMessage(chat : ChatModel, sender : Sender)
    {
        self.refreshDataInView()
    }
}


extension RecentViewController : UICollectionViewDelegate, UICollectionViewDataSource
{
    fileprivate func setupCollectionView()
    {
        let itemHeight = SCREEN_HEIGHT/8 > 80 ? 80 : SCREEN_HEIGHT/8
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: SCREEN_WIDTH , height: itemHeight)
        
        self.recentCollectionView.collectionViewLayout = flowLayout
        self.recentCollectionView.delegate = self
        self.recentCollectionView.dataSource = self
        self.recentCollectionView.showsVerticalScrollIndicator = false
        
        
        let unReadItemHeight = itemHeight*1.2
        topMargin = itemHeight*1.5 + 50
        topMarginLayoutConstraint.constant = topMargin
        unReadViewHeightLayoutConstraint.constant = itemHeight*1.5
        
        let unreadflowLayout = UICollectionViewFlowLayout()
        unreadflowLayout.scrollDirection = .horizontal
        unreadflowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        unreadflowLayout.itemSize = CGSize(width: unReadItemHeight , height: unReadItemHeight)
        unreadflowLayout.minimumLineSpacing = 0
        
        self.unreadCollectionView.collectionViewLayout = unreadflowLayout
        self.unreadCollectionView.delegate = self
        self.unreadCollectionView.dataSource = self
        self.unreadCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == unreadCollectionView
        {
            return self.newChatList?.count ?? 4
        }
        return self.recentChatList?.count ?? 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == unreadCollectionView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: unreadCellIdentifier, for: indexPath) as! RecentUnReadCollectionViewCell
            cell.myProfile = self.myProfile
            cell.chatHistory = self.newChatList?[indexPath.row]
            
            /*
             if let newChatList = self.newChatList
             {
             if newChatList.count > indexPath.row
             {
             cell.myProfile = self.myProfile
             cell.chatHistory = self.newChatList?[indexPath.row]
             }
             }
             */
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentCellIdentifier, for: indexPath) as! RecentCollectionViewCell
            cell.myProfile = self.myProfile
            cell.chatHistory = self.recentChatList?[indexPath.row]
            /*
             if let recentChatList = self.recentChatList
             {
             if recentChatList.count > indexPath.row
             {
             cell.myProfile = self.myProfile
             cell.chatHistory = self.recentChatList?[indexPath.row]
             }
             }
             */
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == unreadCollectionView
        {
            if let newChatList = self.newChatList
            {
                if newChatList.count > indexPath.row
                {
                    let chatHistory = newChatList[indexPath.row]
                    self.openUserProfileViewController(chatHistory : chatHistory)
                }
            }
        }else{
            
            if let recentChatList = self.recentChatList
            {
                if recentChatList.count > indexPath.row
                {
                    let chatHistory = recentChatList[indexPath.row]
                    self.openChatViewController(chatHistory : chatHistory)
                }
            }
        }
    }
}

// API request data
extension RecentViewController {
    
    fileprivate func getRecentListFromServer()
    {
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            RequestManager.shared.getRecentConnectionRequest(bParty: "", onCompletion: { (responseJson) in
                DispatchQueue.main.async {
                    Util.hideLoader()
                    let response =  RecentProfilesResponse.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        if let profileList = response.profileList {
                            for profileobj in profileList{
                                var chatHistory = ChatHistory()
                                chatHistory.avatarUrl = profileobj.imageList?.first?.url
                                chatHistory.connectionStatus = ConnectionStatus.new.rawValue
                                chatHistory.name = profileobj.name
                                chatHistory.uniqueId = profileobj.uniqueId
                                chatHistory.contactNumber = profileobj.contactNumber
                                let profileConnections = response.profileConnectionsList?.filter({$0.bParty == profileobj.uniqueId})
                                chatHistory.createdDate = profileConnections?.first?.timeStamp ?? Date().millisecondsSince1970
                                DatabaseManager.shared.saveUpdateChatHistory(chatHistory: chatHistory)
                            }
                        }
                        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.RECENT_SUCCESS)
                        self.refreshDataInView()
                    }else {
                        print("getRecentListFromServer() failed \(response.reason ?? "")")
                    }
                }
            }) { (error) in
                
                Util.hideLoader()

                print("getRecentListFromServer()  \(error ?? "error" as! Error)")
            }
        }
    }
    
    
    fileprivate func getConnectionListFromServer()
    {
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            RequestManager.shared.getConnectionRequest(bParty: "", onCompletion: { (responseJson) in
                DispatchQueue.main.async {
                    Util.hideLoader()
                    let response =  ConnectionProfilesResponse.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        if let profileList = response.profileList {
                            for profileobj in profileList{
                                var chatHistory = ChatHistory()
                                chatHistory.avatarUrl = profileobj.imageList?.first?.url
                                chatHistory.connectionStatus = ConnectionStatus.connected.rawValue
                                chatHistory.name = profileobj.name
                                chatHistory.uniqueId = profileobj.uniqueId
                                chatHistory.contactNumber = profileobj.contactNumber
                                let profileConnections = response.profileConnectionsList?.filter({$0.bParty == profileobj.uniqueId})
                                chatHistory.createdDate = profileConnections?.first?.timeStamp ?? Date().millisecondsSince1970
                                DatabaseManager.shared.saveUpdateChatHistory(chatHistory: chatHistory)
                            }
                        }
                        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.CONNECTIONS_SUCCESS)
                        self.refreshDataInView()
                    }else {
                        print("getConnectionListFromServer() failed \(response.reason ?? "")")
                    }
                }
            }) { (error) in
                print("getConnectionListFromServer()  \(error ?? "error" as! Error)")
            }
        }
    }
    
    private func checkAndLoadData() {
       
        if UserDefaults.standard.bool(forKey: USER_DEFAULTS.CONNECTIONS_SUCCESS) {
            getConnectionListFromServer()
        }
        if UserDefaults.standard.bool(forKey: USER_DEFAULTS.RECENT_SUCCESS) {
            getRecentListFromServer()
        }
    }
}

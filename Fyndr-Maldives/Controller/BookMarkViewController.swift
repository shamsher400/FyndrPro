//
//  BookmarkViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class BookmarkViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataFoundView : UIView!
    @IBOutlet weak var noDataFoundTitleLbl : UILabel!
    @IBOutlet weak var noDataFoundDescLbl : UILabel!
    
    fileprivate let cellIdentifier = "BookmarkTableViewCell"
    fileprivate var bookmarkList : [BookmarkedProfile]?
    var myProfile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Bookmark", comment: "")
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if (UserDefaults.standard.value(forKey: USER_DEFAULTS.GET_BOOKMARK) != nil)
        {
            self.getBookmarkFromServer()
        }
        
        
        noDataFoundTitleLbl.text = NSLocalizedString("M_BOOKMARK_NO_DATA_FOUND", comment: "")

        noDataFoundDescLbl.text = NSLocalizedString("M_BOOKMARK_NO_DATA_FOUND_DES", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .bookmark))
        TPAnalytics.log(.openScreen(screen: .bookmark))
        myProfile = Util.getProfile()
        self.bookmarkList = DatabaseManager.shared.getBookmarkList()
        reloadDataInView()
    }
    
    fileprivate func reloadDataInView()
    {
        if let bookmarkList = self.bookmarkList
        {
            if bookmarkList.count > 0
            {
                self.noDataFoundView.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }else{
                self.noDataFoundView.isHidden = false
                self.tableView.isHidden = true
            }
        }else{
            self.noDataFoundView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    fileprivate func getBookmarkFromServer()
    {
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            
            RequestManager.shared.getBookmarksRequest(pageIndex: 0, pageSize: 500, onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    let response =  BookmarkResponse.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        if let profileList = response.profileList
                        {
                            if profileList.count > 0 {
                                DatabaseManager.shared.saveUpdateBookmark(profiles: profileList, bookmarkIds: response.bookmarkList)
                                self.bookmarkList = DatabaseManager.shared.getBookmarkList()
                                self.reloadDataInView()
                            }
                        }
                        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.GET_BOOKMARK)
                        UserDefaults.standard.synchronize()
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    Util.hideLoader()
                }
            }
        }
    }

    fileprivate func deleteBookmark(tableView: UITableView, indexPath : IndexPath)
    {
        let blockedProfile = self.bookmarkList?[indexPath.row]
        if let uniqueId = blockedProfile?.uniqueId
        {
            if Reachability.isInternetConnected()
            {
                Util.showLoader()
                
                RequestManager.shared.deleteBookmarkRequest(bookmarkIds: [BookmarkIds.init(uniqueId: uniqueId, timeStamp: blockedProfile?.createdDate)], onCompletion: { (responseJson) in
                    
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        
                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            DatabaseManager.shared.deleteBookmark(uniqueId: uniqueId)
                            self.bookmarkList?.remove(at: indexPath.row)
                            self.deleteCell(indexPath: indexPath)
                        }
                    }
                }) { (error) in
                    Util.hideLoader()
                }
            }else{
                AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
            }
        }
    }
    
    func deleteCell(indexPath: IndexPath)
    {
        if self.bookmarkList?.count == 0
        {
            self.reloadDataInView()
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}


extension BookmarkViewController : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_HEIGHT/8 > 80 ? 80 : SCREEN_HEIGHT/8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BookmarkTableViewCell
        cell.myProfile = myProfile
        if (self.bookmarkList?.count)! > indexPath.row
        {
            cell.bookmarkedProfile = bookmarkList?[indexPath.row]
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        if (self.bookmarkList?.count)! > indexPath.row
        {
            let bookmarkedProfile = bookmarkList?[indexPath.row]
            if let uniqueId = bookmarkedProfile?.uniqueId
            {
                guard let profile = DatabaseManager.shared.getProfile(uniqueId: uniqueId) else {
                    return
                }
                let userDetailViewController = UIStoryboard.getViewController(identifier: "UserDetailViewController") as! UserDetailViewController
                userDetailViewController.profile = profile
                userDetailViewController.updateProfile = true
                self.navigationController?.pushViewController(userDetailViewController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let uniqueId = self.bookmarkList?[indexPath.row].uniqueId{
                AppAnalytics.log(.bookmark(uniqueid: uniqueId, action: "0"))
            }
            self.bookmarkList?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "X") { (action, indexPath) in
            // delete item at indexPath
            self.deleteBookmark(tableView: tableView, indexPath: indexPath)
            
            /*
            if (self.bookmarkList?.count)! > indexPath.row
            {
                let bookmarkedProfile = self.bookmarkList?[indexPath.row]
                if let uniqueId = bookmarkedProfile?.uniqueId
                {
                    self.deleteBookmark(uniqueId : uniqueId)
                }
                self.bookmarkList?.remove(at: indexPath.row)
                
                if self.bookmarkList?.count == 0
                {
                    self.reloadDataInView()
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            */
        }
        return [delete]
    }
}

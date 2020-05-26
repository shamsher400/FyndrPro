//
//  BlockListViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class BlockListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataFoundView : UIView!
    @IBOutlet weak var noDataFoundTitleLbl : UILabel!
    @IBOutlet weak var noDataFoundDescLbl : UILabel!
    
    let cellIdentifier = "BlockListTableViewCell"
    var blockList : [BlockedProfile]?
    var myProfile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Block List", comment: "")
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        noDataFoundTitleLbl.font = UIFont.autoScale(weight: .medium, size: 19)
        noDataFoundDescLbl.font = UIFont.autoScale()
        
        noDataFoundTitleLbl.text = NSLocalizedString("M_BOOKMARK_NO_DATA_FOUND", comment: "")
        noDataFoundDescLbl.text = NSLocalizedString("M_BLOCK_PROFILES_DEC", comment: "")

        
        
        if (UserDefaults.standard.value(forKey: USER_DEFAULTS.GET_BLOCKLIST) != nil)
        {
            self.getBlockListFromServer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppAnalytics.log(.openScreen(screen: .block))
        TPAnalytics.log(.openScreen(screen: .block))
        myProfile = Util.getProfile()
        self.blockList = DatabaseManager.shared.getBlockList()
        reloadDataInView()
    }
    
    fileprivate func reloadDataInView()
    {
        if let blockList = self.blockList
        {
            if blockList.count > 0
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
    
    fileprivate func getBlockListFromServer()
    {
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            
            RequestManager.shared.getBlockListRequest(pageIndex: 0, pageSize: 500, onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    let response =  BlockListResponse.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        if let profileList = response.profileList
                        {
                            if profileList.count > 0 {
                                DatabaseManager.shared.saveUpdateBlockList(profiles: profileList, blockIds :response.blockList)
                                self.blockList = DatabaseManager.shared.getBlockList()
                                self.reloadDataInView()
                                
                                self.tableView.isHidden = false
                                self.noDataFoundView.isHidden = true
                            }else {
                                self.tableView.isHidden = true
                                self.noDataFoundView.isHidden = false
                            }
                        }else {
                            self.tableView.isHidden = true
                            self.noDataFoundView.isHidden = false
                        }
                        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS.GET_BLOCKLIST)
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
    
    fileprivate func unblockProfile(tableView: UITableView, indexPath : IndexPath)
    {
        let blockedProfile = self.blockList?[indexPath.row]
        if let uniqueId = blockedProfile?.uniqueId
        {
            if Reachability.isInternetConnected()
            {
                Util.showLoader()
                
                RequestManager.shared.deleteBlockListRequest(blockListIds: [BlockIds.init(uniqueId: uniqueId)], onCompletion: { (responseJson) in
                    
                    DispatchQueue.main.async {
                        Util.hideLoader()

                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            DatabaseManager.shared.deteleFromBlockList(uniqueId: uniqueId)
                            self.blockList?.remove(at: indexPath.row)
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
        if self.blockList?.count == 0
        {
            self.reloadDataInView()
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}


extension BlockListViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_HEIGHT/8 > 80 ? 80 : SCREEN_HEIGHT/8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BlockListTableViewCell
        cell.myProfile = myProfile
        cell.blockedProfile = blockList?[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        let blockedProfile = blockList?[indexPath.row]
        if let uniqueId = blockedProfile?.uniqueId
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
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.blockList?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Unblock", comment: "") ) { (action, indexPath) in
            // delete item at indexPath
            
            if let blockList = self.blockList {
                if blockList.count > indexPath.row
                {
                    self.unblockProfile(tableView: tableView, indexPath: indexPath)
                }
            }
        }
        return [delete]
    }
}


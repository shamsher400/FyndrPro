//
//  CitySearchViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 06/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class CitySearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var cityList = [City]()
    var filterCitys = [City]()
    let cellIdentifier = "cellIdentifier"
    var citySelectionComplate : ((City, Profile?) -> Void)?
    var myProfile : Profile?
    var selectedCity : City?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("City", comment: "")
        self.setupSearchBar()
        self.tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        cityList = CityListManager.shared.getCityList()
        
        if cityList.count > 0
        {
            self.tableView.reloadData()
            self.updateCityFromServer(blocking: false)
        }else {
            self.updateCityFromServer(blocking: true)
        }
    }
    
    fileprivate func updateCityFromServer(blocking : Bool) {
        if Reachability.isInternetConnected()
        {
            if blocking
            {
                Util.showLoader()
            }
            
            RequestManager.shared.appConfigurationRequest(configurationType : .city, onCompletion: { (responseJson) in
                let response =  Response.init(json: responseJson)
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        CityListManager.shared.initWithJson(json: responseJson)
                        self.cityList = CityListManager.shared.getCityList()
                        self.tableView.reloadData()
                    }else if blocking {
                        // Show failed alert
                        let alertView = AlertView.init()
                        alertView.delegate = self
                        alertView.showAlert(vc: self, message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }) { (error) in
                if blocking {
                    DispatchQueue.main.async {
                        // Show error alert
                        Util.hideLoader()
                        let alertView = AlertView.init()
                        alertView.delegate = self
                        alertView.showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
            }
        } else if blocking {
            let alertView = AlertView.init()
            alertView.delegate = self
            alertView.showAlert(vc: self, message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem?.title = ""
        AppAnalytics.log(.openScreen(screen: .cityList))
        TPAnalytics.log(.openScreen(screen: .cityList))
    }
}


extension CitySearchViewController : AlertViewDelegate {
    func cancelButtonAction(tag: Int) {
        
    }
    func okButtonAction(tag : Int)
    {
        self.navigationController?.popViewController(animated: true)
    }
}


extension CitySearchViewController : UISearchResultsUpdating,UISearchBarDelegate
{
    fileprivate func setupSearchBar()
    {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search City", comment: "")
        searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        //self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchBar.barStyle = UIBarStyle.default
        
        if let buttonItem = self.searchController.searchBar.subviews.first?.subviews.last as? UIButton {
            buttonItem.setTitleColor(UIColor.red, for: .normal)
        }
        self.tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        if searchController.isActive
        {
            if self.searchBarIsEmpty()
            {
                self.filterCitys.removeAll()
                self.filterCitys.append(contentsOf: self.cityList)
            }else{
                self.filterCitys = self.cityList.filter({ (city) -> Bool in
                    city.name?.lowercased().contains(searchText.lowercased()) ?? false
                })
            }
        }else{
            self.filterCitys.removeAll()
        }
        tableView.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        // If the search bar contains text, filter our data with the string
        if let searchText = searchController.searchBar.text {
            print("searchText : \(searchText)")
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Add your search logic here
    }
}


extension CitySearchViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            return self.filterCitys.count
        }
        return self.cityList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_HEIGHT*0.1 < 60 ? SCREEN_HEIGHT*0.1 : 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell =  UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
            cell?.textLabel?.numberOfLines = 0
        }
        var city : City?
        if self.searchController.isActive {
            city = self.filterCitys[indexPath.row]
        }else{
            city = self.cityList[indexPath.row]
        }
        
        cell?.textLabel?.backgroundColor = UIColor.white
        cell?.textLabel?.textColor = UIColor.appCityListTextColor
        
        if let city = city
        {
            cell?.textLabel?.text = city.name
        }
        if self.selectedCity != nil && self.selectedCity?.id == city?.id
        {
            cell?.accessoryType = .checkmark
        }else {
            cell?.accessoryType = .none
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
        
        var city : City?
        if self.searchController.isActive {
            city = self.filterCitys[indexPath.row]
        }else{
            city = self.cityList[indexPath.row]
        }
        guard let citySelectionComplate =  citySelectionComplate, let selectedCity = city else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        citySelectionComplate(selectedCity,myProfile)
        self.navigationController?.popViewController(animated: true)
        
    }
}

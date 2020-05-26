//
//  InterestViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 06/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Kingfisher

class InterestViewController: UIViewController {
    
    @IBOutlet weak var nextButton : UIButton!
    @IBOutlet weak var collectionView : UICollectionView!
    
    //var appConfig : AppConfiguration?
    fileprivate var interestList = [Interest]()
    fileprivate var selectedInterests = [SubCategory]()
    fileprivate let cellIdentifier = "cellIdentifier"
    fileprivate let headerCell = "InterestCollectionReusableView"
    
    var editProfile = false
    var myProfile : Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Select Your interest", comment: "")
        
        if editProfile
        {
            self.nextButton.setTitle(NSLocalizedString("Update", comment: ""), for: .normal)
            if let myInterest = self.myProfile?.interests
            {
                self.selectedInterests = myInterest
            }
        }else{
            self.nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
            myProfile = Util.getProfile()
        }
        setupCollectionView()
        
        if let interestObjList = Util.getInterestList() {
            interestList = interestObjList.interests ?? [Interest]()
            collectionView.reloadData()
        }else {
            Util.showLoader()
        }
        updateInterestFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        openScreenEvent()
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        nextButton.setGradient(colors: defaultGradientColors)
    }
    
    fileprivate func updateInterestFromServer()
    {
        if Reachability.isInternetConnected()
        {
            RequestManager.shared.appConfigurationRequest(configurationType : .interest, onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    let configuration =  AppConfiguration.init(json: responseJson)
                    if configuration.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        let updatedInterestList = InterestList.init(interests: configuration.interests)
                        Util.saveInterestList(interestList: updatedInterestList)
        
                        self.interestList = updatedInterestList.interests ?? [Interest]()
                        self.collectionView.reloadData()
                    }
                }
            }) { (error) in
            }
        }
    }
    
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        let selectedSubCategoryIds = selectedInterests.map { (subCategory)  in
            subCategory.id
        }
        let subCategoryIds = selectedSubCategoryIds.compactMap({return $0})
        if subCategoryIds.count > 0
        {
            updateInterestOnServer(subCategoryIds : subCategoryIds)
        }else{
            AlertView().showAlert(vc: self, message: NSLocalizedString("M_NO_INTEREST_SELECTED", comment: ""))
        }
    }
    
    fileprivate func updateInterestOnServer(subCategoryIds : [String])
    {
        if Reachability.isInternetConnected()
        {
            Util.showLoader()
            
            RequestManager.shared.updateInterestRequest(interestList: subCategoryIds, onCompletion: { (responseJson) in
                
                DispatchQueue.main.async {
                    Util.hideLoader()
                    
                    let response =  Response.init(json: responseJson)
                    if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                    {
                        var myProfile = Util.getProfile()
                        myProfile?.isInterest = true
                        myProfile?.interests = self.selectedInterests
                        Util.saveProfile(myProfile: myProfile)
                        
                        if self.editProfile {
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            APP_DELEGATE.openScreen(screenName: Util.getCurrentScreen().0, firstScreen: false)
                        }
                    }else {
                        AlertView().showNotficationMessage(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                    }
                }
                
            }) { (error) in
                DispatchQueue.main.async {
                    Util.hideLoader()
                    AlertView().showAlert(vc: self, message: NSLocalizedString("M_GENERIC_ERROR", comment: ""))
                }
            }
        }else {
            AlertView().showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
}


extension InterestViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    fileprivate func setupCollectionView()
    {
        self.collectionView.register(UINib.init(nibName: "InterestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    
        let flowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 20, right: 10)
        flowLayout.headerReferenceSize = CGSize(width: SCREEN_WIDTH, height: 30)
        
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return interestList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCell, for: indexPath) as? InterestCollectionReusableView {
            sectionHeader.sectionHeaderlabel.text = self.interestList[indexPath.section].name
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var headerHeight = SCREEN_HEIGHT * 0.09
        if headerHeight > 50
        {
            headerHeight = 50
        }
        return CGSize(width: SCREEN_WIDTH, height: headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.interestList[section].subcategory?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:cellIdentifier , for: indexPath) as! InterestCollectionViewCell
        let subCategory = interestList[indexPath.section].subcategory?[indexPath.row]
        cell.myProfile = self.myProfile
        cell.subCategory = subCategory
        
        print("subCategory - \(subCategory?.thumbUrl)")
        
        if isSelected(subCategory: subCategory)
        {
            cell.selectedInterest = true
        }else {
            cell.selectedInterest = false
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let subCategoryObj = interestList[indexPath.section].subcategory?[indexPath.row]
        
        guard let subCategory = subCategoryObj else {
            return
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? InterestCollectionViewCell {
            
            if isSelected(subCategory: subCategory)
            {
                guard let index = self.selectedInterests.firstIndex(where: { $0 == subCategory}) else {
                    return
                }
                self.selectedInterests.remove(at:index)
                cell.selectedInterest = false
            }else{
                self.selectedInterests.append(subCategory)
                cell.selectedInterest = true
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let string : String = interestList[indexPath.section].subcategory?[indexPath.row].name ?? ""
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.autoScale(weight: .regular, size: CGFloat(14))
        label.text = string
        label.sizeToFit()
        let height = label.frame.height*2
        let iconSize = height*0.7
        let width = label.frame.width  + iconSize + 30
        return CGSize(width: width, height: height)
        
    }
    
    fileprivate func isSelected(subCategory : SubCategory?) -> Bool
    {
        guard let subCategory = subCategory else {
            return false
        }
        return selectedInterests.contains(subCategory)
    }
}


extension InterestViewController {
    func openScreenEvent() {
        AppAnalytics.log(.openScreen(screen: .interest))
        TPAnalytics.log(.openScreen(screen: .interest))

    }
}

//
//  InterestCollectionViewCell.swift
//  Fyndr
//
//  Created by BlackNGreen on 07/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Kingfisher

class InterestCollectionViewCell: UICollectionViewCell {
    
    var onCellTap : ((_ category : String , _ selected : Bool) -> Void)?
    
    @IBOutlet weak var cardView : CardView!
    @IBOutlet weak var subCatLabel : UILabel!
    @IBOutlet weak var icon : UIImageView!
    var myProfile : Profile?
    
    var subCategory : SubCategory?
    {
        didSet {
            guard let subCat = subCategory else {
                return
            }
            subCatLabel.text = subCat.name
            self.isSelected = subCat.selected
            icon.image = Util.defaultInterestImage()
            showImageForState(selected: false)
        }
    }
    
    fileprivate func showImageForState(selected : Bool)
    {
        if let uniqueId = self.myProfile?.uniqueId , let imgUrl = subCategory?.thumbUrl
        {
            var imageUrl = imgUrl
            if selected
            {
                if let selectedImgUrl = subCategory?.selectedThumbUrl
                {
                    imageUrl = selectedImgUrl
                }
            }
            
            if imageUrl == "addMore" {
                let image = Image.init(named: "add_icon")
                icon.image = image
            }else {
                icon.setKfImage(url: imageUrl, placeholder: Util.defaultInterestImage(), uniqueId: uniqueId)
            }
        } 
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subCatLabel.font = UIFont.autoScale(weight: .regular, size: 14)
    }
    
    var selectedInterest : Bool? {
        didSet {
            
            guard let selectedInterest = selectedInterest else {
                return
            }
            if selectedInterest {
                // animate selection
//                cardView.borderColor = UIColor.appPrimaryColor
//                subCatLabel.textColor = UIColor.appPrimaryColor
                
                cardView.backgroundColor = UIColor.appPrimaryColor
                subCatLabel.textColor = UIColor.white
                cardView.borderColor = UIColor.appPrimaryColor
                showImageForState(selected: true)
                
            } else {
                // animate deselection
//                cardView.borderColor = UIColor.lightGray
//                subCatLabel.textColor = UIColor.darkGray
                
                cardView.backgroundColor = UIColor.customLightGray
                subCatLabel.textColor = UIColor.black
                cardView.borderColor = UIColor.customLightGray
                showImageForState(selected: false)

            }
        }
    }
}

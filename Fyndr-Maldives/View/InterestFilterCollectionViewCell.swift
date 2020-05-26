//
//  InterestFilterCollectionViewCell.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Kingfisher

class InterestFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumb: UIButton!
    @IBOutlet weak var interestLebel: UILabel!
    
    //let defaultImg = UIImage(named: "default_filter_icon")
    let defaultImg = UIImage.init(named: "default_filter_icon", in: nil, compatibleWith: nil)
    var myProfile : Profile?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.interestLebel.font = UIFont.autoScale(weight: .regular, size: 13)
    }
    
    var interest : Interest? {
        didSet
        {
            self.interestLebel.text = interest?.name
            if let uniqueId = myProfile?.uniqueId
            {
                self.thumb.setBackgroundImage(nil, for: .normal)
                self.thumb.setBackgroundImage(nil, for: .selected)

                if let urlString = interest?.thumbUrl
                {
                    self.thumb.setKfImage(url: urlString, selectedUrl: interest?.selectedThumbUrl, placeholder: defaultImg, uid: uniqueId) 
                }else {
                    self.thumb.setBackgroundImage(defaultImg, for: .normal)
                }
            }
        }
    }
    
    var selectedInterest : Bool = false {
        didSet {
            if selectedInterest {
                self.thumb.layer.borderWidth = 3
                self.thumb.layer.cornerRadius =  self.thumb.bounds.size.width/2
                self.thumb.layer.borderColor = UIColor.selectedCategoryColor.cgColor
                self.thumb.isSelected = true
            }else{
                self.thumb.layer.borderWidth = 3
                self.thumb.layer.cornerRadius =  self.thumb.bounds.size.width/2
                self.thumb.layer.borderColor = UIColor.categoryOutLineColor.cgColor
                self.thumb.isSelected = false
                self.thumb.backgroundColor = .yellow


            }
        }
    }
}

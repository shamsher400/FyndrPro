//
//  RecentUnReadCollectionViewCell.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class RecentUnReadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    
    var myProfile : Profile?
    var chatHistory : ChatHistory?
    {
        
        didSet {
            guard let chatHistory = chatHistory else {
                self.nameLabel.text = ""
                return
            }
            nameLabel.font = UIFont.autoScale(weight: .regular, size: 13)
            self.nameLabel.text = chatHistory.name
            
            if let urlString = chatHistory.avatarUrl
            {
                profilePic.setKfImage(url: urlString, placeholder: Util.defaultThumImage(), uniqueId: myProfile?.uniqueId)
            }else {
                profilePic.image = Util.defaultThumImage()
            }
        }
    }
    
}

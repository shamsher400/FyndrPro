//
//  RecentCollectionViewCell.swift
//  Fyndr
//
//  Created by BlackNGreen on 09/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Kingfisher

class RecentCollectionViewCell: UICollectionViewCell {
    
    var chatButtonPressed : ((String?) -> Void)?
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var lastMessageLabel : UILabel!
    @IBOutlet weak var lastSeenLabel : UILabel!
    @IBOutlet weak var unreadMessageCount : UILabel!

    var myProfile : Profile?

    var chatHistory : ChatHistory?
    {
        didSet {
            guard let chatHistory = chatHistory else {
                self.nameLabel.text = ""
                self.lastMessageLabel.text = ""
                self.lastSeenLabel.text = ""
                self.unreadMessageCount.text = ""
                self.unreadMessageCount.isHidden = true
                return
            }
            
            self.nameLabel.font = UIFont.autoScale()
            self.nameLabel.text = chatHistory.name
            self.lastMessageLabel.font = UIFont.autoScale(weight: .regular, size: 12)
            self.unreadMessageCount.font = UIFont.autoScale(weight: .medium, size: 13)
            self.lastMessageLabel.text = chatHistory.lastMessage
            
            if chatHistory.createdDate == 0
            {
                self.lastSeenLabel.text = ""
            }else{
                self.lastSeenLabel.text = Date.init(milliseconds: chatHistory.createdDate).chatTime
            }
            self.unreadMessageCount.text = String(chatHistory.unReadMessageCount)

            if chatHistory.unReadMessageCount == 0
            {
                self.unreadMessageCount.isHidden = true
            }else{
                self.unreadMessageCount.isHidden = false
            }

            if let urlString = chatHistory.avatarUrl
            {
                profilePic.setKfImage(url: urlString, placeholder: Util.defaultThumImage(), uniqueId: myProfile?.uniqueId)
            }else{
                profilePic.image = Util.defaultThumImage()
            }
        }
    }
    
}

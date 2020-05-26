//
//  BookmarkTableViewCell.swift
//  Fyndr
//
//  Created by BlackNGreen on 10/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import Kingfisher

class BookmarkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var connectedIcon : UIImageView!

    var myProfile : Profile?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.nameLabel.font = UIFont.autoScale(weight: .medium, size: 17)
        self.lastSeenLabel.font = UIFont.autoScale(weight: .regular, size: 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    var bookmarkedProfile : BookmarkedProfile?
    {
        didSet {
            guard let bookmarkedProfile = bookmarkedProfile else {
                return
            }
            self.nameLabel.text = bookmarkedProfile.name
            self.lastSeenLabel.text = Date.init(milliseconds: bookmarkedProfile.createdDate).elapsedInterval()
            
            guard let myProfile = myProfile else {
                return
            }
            
            if let urlString = bookmarkedProfile.avatarUrl
            {
                profilePic.setKfImage(url: urlString, placeholder: Util.defaultThumImage(), uniqueId: myProfile.uniqueId)
            }
        }
    }
}

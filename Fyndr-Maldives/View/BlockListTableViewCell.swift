//
//  BlockListTableViewCell.swift
//  Fyndr
//
//  Created by BlackNGreen on 02/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class BlockListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var connectedIcon : UIImageView!
    
    var myProfile : Profile?

    var blockedProfile : BlockedProfile?
    {
        didSet {
            guard let blockedProfile = blockedProfile else {
                return
            }
            self.nameLabel.text = blockedProfile.name
            self.nameLabel.font = UIFont.autoScale()
            self.lastSeenLabel.font = UIFont.autoScale(weight: .regular, size: 13)
            self.lastSeenLabel.text = Date.init(milliseconds: blockedProfile.createdDate).elapsedInterval() 
            
            guard let myProfile = myProfile else {
                return
            }
            
            if let urlString = blockedProfile.avatarUrl
            {
                profilePic.setKfImage(url: urlString, placeholder: Util.defaultThumImage(), uniqueId: myProfile.uniqueId)
            }
        }
    }
    
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
    
}

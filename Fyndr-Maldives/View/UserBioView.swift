//
//  UserBioView.swift
//  Fyndr
//
//  Created by BlackNGreen on 26/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class UserBioView: UIView {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    
    @IBOutlet weak var noVideoView: UIView!
    @IBOutlet weak var noVideoLbl: UILabel!

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!

    
    override func awakeFromNib() {
        
        noVideoLbl.text = NSLocalizedString("M_ADD_YOUR_VEDIO", comment: "")

        //  complexShape()
        //  self.backgroundColor = UIColor.orange
        
        
        
    }
    
    @IBAction func playPauseButtonAction(_ sender: Any) {
    }
    
    
}

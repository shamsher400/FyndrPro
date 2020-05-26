//
//  AppPurchaseCell.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 25/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class AppPurchaseCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnPackSelected.setTitle(NSLocalizedString("M_BUY_NOW", comment: ""), for: .normal)
        // Initialization code
    }
    @IBOutlet weak var lblPackTitle: UILabel!
    @IBOutlet weak var lblPackDiscription: UILabel!
    @IBOutlet weak var lblPackShortDesc: UILabel!

    @IBOutlet weak var btnPackSelected: UIButton!
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}

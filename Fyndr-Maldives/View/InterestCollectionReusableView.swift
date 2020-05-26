//
//  InterestCollectionReusableView.swift
//  Fyndr
//
//  Created by BlackNGreen on 07/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class InterestCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var sectionHeaderlabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.sectionHeaderlabel.font = UIFont.autoScale(weight: .medium, size: 17)
    }
    
}

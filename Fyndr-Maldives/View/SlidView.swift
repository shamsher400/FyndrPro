//
//  SlidView.swift
//  Fyndr
//
//  Created by BlackNGreen on 22/04/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class SlidView: UIView {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDesc : UILabel!
    @IBOutlet weak var slidImg : UIImageView!
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override func awakeFromNib() {
        self.lblTitle.font = UIFont.autoScale(weight: .semibold, size: 24)
        self.lblDesc.font = UIFont.autoScale(weight: .regular, size: 18)
    }

    func initWithSlidItem(sliderItem : SliderItem) {
        self.lblTitle.text = sliderItem.title
        self.lblDesc.text = sliderItem.desc?.uppercased()
        self.slidImg.image = UIImage.init(named: sliderItem.imageName ?? "")
    }
    
    /*
    func initWithSlidItem(sliderItem : SliderItem) -> SlidView {
        
        guard  let slidViewObj = Bundle.main.loadNibNamed("SlidView", owner: self, options: nil)?.first else {
            return SlidView()
        }
        let slidView = slidViewObj as! SlidView
        slidView.lblTitle.text = sliderItem.title
        slidView.lblDesc.text = sliderItem.desc
        slidView.slidImg.image = UIImage.init(named: sliderItem.imageName ?? "")
        return slidView
    }
    */
}

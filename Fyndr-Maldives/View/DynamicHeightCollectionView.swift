//
//  DynamicHeightCollectionView.swift
//  Fyndr
//
//  Created by BlackNGreen on 24/07/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

class DynamicHeightCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

}

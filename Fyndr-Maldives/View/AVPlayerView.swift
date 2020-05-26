//
//  AVPlayerView.swift
//  Fyndr
//
//  Created by BlackNGreen on 26/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import AVFoundation


class AVPlayerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

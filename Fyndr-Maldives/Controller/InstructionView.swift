//
//  InstructionView.swift
//  Fyndr
//
//  Created by Shamsher Singh on 12/09/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import UIKit


protocol InstructionViewDelegate {
    func okButtonAction(tag : Int)
    func skipButtonAction(tag : Int)
}

class InstructionView {
    private var viewController: UIViewController?
    private var delegate: InstructionViewDelegate?
    private let instructionViewContainer = UIView.init()
    public func setDelegate(delegate: InstructionViewDelegate){
        self.delegate = delegate
    }
    
    func setViewOnController(){
        let window = UIApplication.shared.keyWindow!
        let v = UIView(frame: window.bounds)
        window.addSubview(v);
        v.backgroundColor = UIColor.clear
        let v2 = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 50))
        v2.backgroundColor = UIColor.white
        v.addSubview(v2)
    }
    
    
    
    
    
    func setViewWithButtons() {}
    
    func addViewInBottoms(){
        
    }

    
}

//
//  ArcView.swift
//  Fyndr
//
//  Created by BlackNGreen on 19/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit

@IBDesignable
class ArcView: UIView {

    var path: UIBezierPath!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
      //  complexShape()
      //  self.backgroundColor = UIColor.orange
    }
    
    override func draw(_ rect: CGRect) {
        drawArc()
    }
    
    
    fileprivate func drawArc()
    {
        path = UIBezierPath()
        path.move(to: CGPoint(x: -bounds.width/4, y: bounds.height))
        path.addCurve(to: CGPoint(x: bounds.width + bounds.width/4, y: bounds.height), controlPoint1: CGPoint(x: bounds.width/4, y: bounds.height/2), controlPoint2: CGPoint(x: bounds.width*3/4, y: bounds.height/2))
        UIColor.white.setFill()
        path.fill()
    }
    
    func complexShape() {
        let path = UIBezierPath()
        //  path.move(to: CGPoint(x: 0.0, y: 0.0))
        
        // path.addLine(to: CGPoint(x: self.view.frame.size.width/2 - 50.0, y: 50.0))
        //        path.addArc(withCenter: CGPoint(x: self.view.frame.size.width/2 - 25.0, y: 75.0),
        //                    radius: 25.0,
        //                    startAngle: CGFloat(180.0).degreesToRadians,
        //                    endAngle: CGFloat(0.0).degreesToRadians,
        //                    clockwise: false)
        
        
        path.addArc(withCenter: CGPoint(x: self.frame.size.width/2, y: 100),
                    radius: 50,
                    startAngle: CGFloat(0.0).degreesToRadians,
                    endAngle: CGFloat(180.0).degreesToRadians,
                    clockwise: false)
        
        // path.addLine(to: CGPoint(x: self.view.frame.size.width/2, y: 0.0))
        // path.addLine(to: CGPoint(x: self.view.frame.size.width - 50.0, y: 0.0))
       
       // path.addCurve(to: CGPoint(x: self.frame.size.width, y: 50.0),
        //               controlPoint1: CGPoint(x: self.frame.size.width + 50.0, y: 25.0),
        //               controlPoint2: CGPoint(x: self.frame.size.width - 150.0, y: 50.0))
        
        // path.addLine(to: CGPoint(x: self.view.frame.size.width, y: self.view.frame.size.height))
        // path.addLine(to: CGPoint(x: 0.0, y: self.view.frame.size.height))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        self.backgroundColor = UIColor.orange
        self.layer.mask = shapeLayer
    }

    
}


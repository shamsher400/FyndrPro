//
//  AlertView.swift
//  Fyndr
//
//  Created by BlackNGreen on 29/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import NotificationView

protocol AlertViewDelegate {
    func okButtonAction(tag : Int)
    func cancelButtonAction(tag : Int)
}

class AlertView  {
    
    // delegate object that implements the protocol
    var delegate: AlertViewDelegate?
    
    func setDelegate(delegate : AlertViewDelegate) {
        self.delegate = delegate;
    }
    
    func showAlert(vc : UIViewController, message: String)
    {
        self.showAlert(vc: vc, title: "", message: message, okButtonTitle: NSLocalizedString("OK", comment: ""), cancelButtonTitle: nil, tag: 0)
    }
    
    func showAlert(vc : UIViewController, title: String, message: String, okButtonTitle : String?, cancelButtonTitle : String?, tag : Int){
        
        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if okButtonTitle != nil{
            
            let okAction = UIAlertAction(title: okButtonTitle, style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.delegate?.okButtonAction(tag: tag)
            }
            alertController.addAction(okAction)
        }
        
        if cancelButtonTitle != nil{
            
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.delegate?.cancelButtonAction(tag: tag)
            }
            alertController.addAction(cancelAction)
        }
        vc.modalPresentationStyle = .fullScreen
        vc.present(alertController, animated: true, completion: nil)
    }
    
    
    func showAlert(vc : UIViewController, title: String?, message: String, okButtonTitle : String?, deleteButtonTitle : String?, tag : Int){
        
        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if okButtonTitle != nil{
            
            let okAction = UIAlertAction(title: okButtonTitle, style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.delegate?.okButtonAction(tag: tag)
            }
            alertController.addAction(okAction)
        }
        
        if deleteButtonTitle != nil{
            
            let cancelAction = UIAlertAction(title: deleteButtonTitle, style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                self.delegate?.cancelButtonAction(tag: tag)
            }
            alertController.addAction(cancelAction)
        }
        vc.modalPresentationStyle = .fullScreen
        vc.present(alertController, animated: true, completion: nil)
    }
    
    
    func showNotficationMessage(message : String)
    {
        let notificationView = NotificationView.default
        notificationView.body = message
        notificationView.show()
    }
}



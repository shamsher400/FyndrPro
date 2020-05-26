//
//  RegistrationPresenter.swift
//  Fyndr
//
//  Created by BlackNGreen on 21/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

protocol RegistrationDelegate{
    func showProgress()
    func hideProgress()
    func registrationDidSucceed()
    func registrationDidFailed(message: String)
}


class RegistrationPresenter {
    var delegate: RegistrationDelegate
    
    init(delegate: RegistrationDelegate) {
        self.delegate = delegate
    }

    func register(email: String, password: String, fullName: String, phoneNumber:String){
        if email.isEmpty{
            print("omayib")
            self.delegate.registrationDidFailed(message: "email can't be blank")
        }
    }
    
}

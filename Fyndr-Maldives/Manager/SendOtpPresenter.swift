//
//  SendOtpPresenter.swift
//  Fyndr
//
//  Created by Shamsher Singh on 09/08/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation


protocol SendOtpDelegate {
    func onSuccess(msisdn : String, callingCode : String, message : String?)
    func onFailed(message : String, nonOtp : Bool?)
}



class SendOtpPresenter {
    
    private var delegate : SendOtpDelegate?
    
    func setDelegate(delegate : SendOtpDelegate)
    {
        self.delegate = delegate
    }
    
    
    func requestOtp(msisdn : String , callingCode : String) {
        
        if Reachability.isInternetConnected()
        {
            print("")
            Util.setUserCountryCode(countryCode: callingCode)
            
            let numberWithCallingCode = "\(callingCode)\(msisdn)".removePlus()
            
            RequestManager.shared.sendOtpRequest(numberWithCallingCode: numberWithCallingCode, callingCode: callingCode, onCompletion: { (responseJson) in
                
                let response =  SendOtpResponse.init(json: responseJson)
                if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                {
                    
                    self.delegate?.onSuccess(msisdn: msisdn, callingCode: callingCode, message: response.reason)
                }else {
                    self.delegate?.onFailed(message: response.reason ?? NSLocalizedString("M_GENERIC_ERROR", comment: ""), nonOtp: response.noOtp)
                }
                
            }) { (error) in
                self.delegate?.onFailed(message: NSLocalizedString("M_GENERIC_ERROR", comment: ""), nonOtp: false)
            }
        }
        else {
            self.delegate?.onFailed(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""), nonOtp: false)
        }
    }
}

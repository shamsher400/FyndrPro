//
//  InAppPaymentRequest.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 03/10/19.
//  Copyright © 2019 BNG. All rights reserved.
//


import UIKit


class InAppPaymentRequest: NSObject {
    
    var paymentType : String = "APPLE"
    var receipt : String = ""
    var txnStatus : String = "failure"
    var txnid : String? = nil
    var productId : String = ""
    var transactionId : String = ""
    
}

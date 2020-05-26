//
//  PendingPackModel.swift
//  Fyndr-MMR
//
//  Created by Shamsher Singh on 08/11/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

struct PendingPackModel: Codable {
    
    public var status: String?
    public var packId: String?
    public var orderId: String?
    
    public init(){}

    
    
    func save()
    {
        UserDefaults.standard.save(customObject: self, inKey: USER_DEFAULTS.PEDING_PACK)
        UserDefaults.standard.synchronize()
    }
    
    
    func getPendingPackModel() -> PendingPackModel?{
        if let pendingPackModel = UserDefaults.standard.retrieve(object: PendingPackModel.self, fromKey: USER_DEFAULTS.PEDING_PACK)
        {
            return pendingPackModel
        }
        return nil
    }
}

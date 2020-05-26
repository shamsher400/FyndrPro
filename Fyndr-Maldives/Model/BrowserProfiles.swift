//
//  BrowserProfileResponse.swift
//  Fyndr
//
//  Created by BlackNGreen on 31/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

class BrowserProfiles : Codable {
    
    // MARK: Properties
    public var profiles: [Profile]?
    
    init()
    {
        if let lastSavedProfiles = UserDefaults.standard.retrieve(object: BrowserProfiles.self, fromKey: USER_DEFAULTS.BROWSE_PROFILE_LIST)
        {
            self.profiles = lastSavedProfiles.profiles
        }
    }
    
    func initWithProfileList(profiles : [Profile]?)
    {
        self.profiles = profiles
    }
    
    func appendProfiles(profiles : [Profile]?)
    {
        guard let profiles = profiles else {
            return
        }
        self.profiles?.append(contentsOf: profiles)
    }
    
    func deleteProfile(profile : Profile?)
    {
        self.profiles = self.profiles?.filter({ $0.uniqueId  !=  profile?.uniqueId})
    }
    
    func save()
    {
        UserDefaults.standard.save(customObject: self, inKey: USER_DEFAULTS.BROWSE_PROFILE_LIST)
        UserDefaults.standard.synchronize()
    }
    
    func getProfileForInterestCategory(categoryId : String?) -> [Profile]?
    {
        guard let categoryId = categoryId else {
            return nil
        }
        let profiles = self.profiles?.filter({
            $0.interestCategory?.contains(where: { (interest) -> Bool in interest.id == categoryId }) ?? false
        })
        return profiles
    }
}

//
//  CityListManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 30/05/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation
import SwiftyJSON

class  CityListManager {
    
    static let shared = CityListManager()
    private init() { }
    fileprivate var cityList = [City]()
    
    private struct SerializationKeys {
        static let cityList = "cityList"
    }
    
    func initWithJson(json : JSON) {
        cityList.removeAll()
        
        UserDefaults.standard.set(json[SerializationKeys.cityList].debugDescription, forKey: USER_DEFAULTS.CITY_LIST)
        UserDefaults.standard.synchronize()
        
        guard let cityObjList = json[SerializationKeys.cityList].array else {
            return
        }
        for cityObj : JSON in cityObjList
        {
            let city = City.init(json: cityObj)
            cityList.append(city)
        }
        cityList.sort(by: {$0.name ?? "" < $1.name ?? ""})
    }
    
    fileprivate func initSavedCity()
    {
        if let cityJsonString = UserDefaults.standard.value(forKey: USER_DEFAULTS.CITY_LIST) as? String
        {
            let cityJson = JSON.init(parseJSON: cityJsonString)
            initWithJson(json: cityJson)
        }
    }
    
    
    func getCityList() -> [City]
    {
        if cityList.count > 0
        {
            return cityList
        }else {
            initSavedCity()
            return cityList
        }
    }
}

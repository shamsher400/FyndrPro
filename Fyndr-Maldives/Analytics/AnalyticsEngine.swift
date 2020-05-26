//
//  AnalyticsEngine.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

protocol AnalyticsEngine: class {
    func sendAnalyticsEvent(name: String, parameter: [String : Any])
}

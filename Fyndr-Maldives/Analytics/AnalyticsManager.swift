//
//  AnalyticsManager.swift
//  Fyndr
//
//  Created by BlackNGreen on 27/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

class AnalyticsManager {
    private let engine: AnalyticsEngine
    
    init(engine: AnalyticsEngine) {
        self.engine = engine
    }
    func log(_ event: AnalyticsEvent) {
        engine.sendAnalyticsEvent(name: event.name, parameter: event.parameter)
    }
    
    func log(eventName: String, parameter : [String: Any]) {
        engine.sendAnalyticsEvent(name: eventName, parameter: parameter)
    }
}

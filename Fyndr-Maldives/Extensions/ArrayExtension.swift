//
//  ArrayExtension.swift
//  Fyndr
//
//  Created by BlackNGreen on 16/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation

protocol Dated {
    var date: Date { get }
}

extension Array where Element : Dated {
    func groupedBy(dateComponents: Set<Calendar.Component>) -> [Date: [Element]] {
        let initial: [Date: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur.date)
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
        return groupedByDateComponents
    }
}

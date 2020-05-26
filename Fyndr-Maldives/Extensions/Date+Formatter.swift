//
//  Date+Formatter.swift
//  Fyndr
//
//  Created by BlackNGreen on 05/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import Foundation


extension Date
{
    func elapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        }else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour)" + " " + "day ago" :
                "\(hour)" + " " + "days ago"
        } else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "\(minute)" + " " + "day ago" :
                "\(minute)" + " " + "days ago"
        }
        else {
            return "a moment ago"
        }
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    func isInSameDayOf(date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs:date)
    }
    
    // you can create a read-only computed property to return just the nanoseconds from your date time
    var nanosecond: Int { return Calendar.current.component(.nanosecond,  from: self)  }
    
    // the same for your local time
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
    
    var chatTime : String {
        return DateFormatter.init(date: self).string(from: self)
    }
}

extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}


extension DateFormatter
{
    convenience init(date: Date) {
        self.init()
        switch true {            
        case Calendar.current.isDateInToday(date):
            self.doesRelativeDateFormatting = true
            self.timeStyle = .short
        case Calendar.current.isDateInYesterday(date):
            self.doesRelativeDateFormatting = true
            self.dateStyle = .short
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear):
            self.dateFormat = "EEEE"
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year):
            self.dateFormat = "dd/MM/yy"
        default:
            self.dateFormat = "dd/MM/yy"
        }
    }
}

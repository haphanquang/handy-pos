//
//  BusinessDate.swift
//  HandyPos
//
//  Created by Phan, Quang Ha | Kawa | RP on 2022/01/02.
//

import Foundation

struct BusinessDate: Codable, Equatable, Hashable {
    var start: Date = Date().startOfDay()
    var end: Date?
    
    var symbol: String {
        let calendar = Calendar(identifier: .gregorian)
        let days = calendar.weekdaySymbols
        return days[calendar.component(.weekday, from: start) - 1]
    }
    
    var day: String {
        let calendar = Calendar(identifier: .gregorian)
        let day = calendar.component(.day, from: start)
        return String(format: "%02d", day)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(start)
    }
    
}

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    func endOfDay() -> Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
}

extension Date {
    var recent7Days: [Date] {
        return ((-7)...0).compactMap { val in
            return Calendar.current.date(byAdding: DateComponents(day: val), to: self)
        }
    }
    var recent30Days: [Date] {
        return ((-30)...0).compactMap { val in
            return Calendar.current.date(byAdding: DateComponents(day: val), to: self)
        }
    }
}

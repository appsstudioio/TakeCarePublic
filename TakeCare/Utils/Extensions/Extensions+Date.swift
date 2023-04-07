//
//  Extensions+Date.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation

extension Date {
    public enum DateWeekType: Int {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }

    // returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
    func dayOfWeek(timeZone: TimeZone = TimeZone.autoupdatingCurrent, locale: Locale? = Locale.current) -> DateWeekType? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = locale
        guard let weekday = calendar.dateComponents([.weekday], from: self).weekday else { return nil }

        switch weekday {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return nil
        }
    }

    func dayOfWeekString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.setFormatter(timeZone: TimeZone.current, dateFormat: "EEEE")
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }

    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    func toString(timeZone: TimeZone = .current, format: String, locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setFormatter(timeZone: timeZone, dateFormat: format, locale: locale)
        return dateFormatter.string(from: self)
    }

    // D-Day
    func betweenDates(toDate: Date, component: [Calendar.Component]) -> DateComponents? {
        let calendar = Calendar(identifier: .gregorian)
    //    calendar.locale = Locale(identifier: "ko_KR")
        let unitFlags = Set<Calendar.Component>(component)
        let components = calendar.dateComponents(unitFlags, from: self, to: toDate)
        return components
    }

    func afterMonthDate(month: Int) -> Date? {
        let monthOffset = DateComponents(month: month)
        let calendar = Calendar(identifier: .gregorian)
        if let afterMonth = calendar.date(byAdding: monthOffset, to: self) {
            return afterMonth
        }
        return nil
    }

    func afterHourDate(hour: Int) -> Date? {
        let hourOffset = DateComponents(hour: hour)
        let calendar = Calendar(identifier: .gregorian)
        if let afterHour = calendar.date(byAdding: hourOffset, to: self) {
            return afterHour
        }
        return nil
    }

    func afterMinuteDate(minute: Int) -> Date? {
        let hourOffset = DateComponents(minute: minute)
        let calendar = Calendar(identifier: .gregorian)
        if let afterMinute = calendar.date(byAdding: hourOffset, to: self) {
            return afterMinute
        }
        return nil
    }

    func afterDayDate(day: Int) -> Date? {
        let dayOffset = DateComponents(day: day)
        let calendar = Calendar(identifier: .gregorian)
        if let afterDay = calendar.date(byAdding: dayOffset, to: self) {
            return afterDay
        }
        return nil
    }

    var dateKST: Date? {
        return datetime_KST()
    }

    func datetime_KST() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.setKSTFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")
        let dateStr = dateFormatter.string(from: self)
        return dateFormatter.date(from: dateStr)!
    }

//    func dateNationFormat(timeZone: TimeZone = TimeZone(abbreviation: "KST") ?? .autoupdatingCurrent,
//                          isTime: Bool = true,
//                          isYear: Bool = true,
//                          isTime24: Bool = false) -> String {
//        var dateFormatString = ""
//        switch lang {
//        case "ko": // 한국
//            let timeFormat: String = (isTime24 ? "HH:mm" : "a hh:mm")
//            if isYear {
//                dateFormatString = isTime ? "yyyy.MM.dd \(timeFormat)" : "yyyy.MM.dd"
//            } else {
//                dateFormatString = isTime ? "MM.dd \(timeFormat)" : "MM.dd"
//            }
//        case "ja": // 일본
//            let timeFormat: String = (isTime24 ? "HH:mm" : "a hh:mm")
//            if isYear {
//                dateFormatString = isTime ? "yyyy.MM.dd \(timeFormat)" : "yyyy.MM.dd"
//            } else {
//                dateFormatString = isTime ? "MM.dd \(timeFormat)" : "MM.dd"
//            }
//        case "en", "es": // 영문
//            let timeFormat: String = (isTime24 ? "HH:mm" : "hh:mm a")
//            if isYear {
//                dateFormatString = isTime ? "MMM dd yyyy, \(timeFormat)" : "MMM dd yyyy"
//            } else {
//                dateFormatString = isTime ? "MMM dd, \(timeFormat)" : "MMM dd"
//            }
//        case "zh", "zhtw": // 중국어
//            let timeFormat: String = (isTime24 ? "HH:mm" : "a hh:mm")
//            if isYear {
//                dateFormatString = isTime ? "yyyy.MM.dd \(timeFormat)" : "yyyy.MM.dd"
//            } else {
//                dateFormatString = isTime ? "MM.dd \(timeFormat)" : "MM.dd"
//            }
//        case "id": // 인도네시아
//            let timeFormat: String = (isTime24 ? "HH:mm" : "hh:mm a")
//            if isYear {
//                dateFormatString = isTime ? "dd/MM/yyyy, \(timeFormat)" : "dd/MM/yyyy"
//            } else {
//                dateFormatString = isTime ? "dd/MM, \(timeFormat)" : "dd/MM"
//            }
//
//        case "vi": // 베트남
//            let timeFormat: String = (isTime24 ? "HH:mm" : "hh:mm a")
//            if isYear {
//                dateFormatString = isTime ? "dd/MM/yyyy, \(timeFormat)" : "dd/MM/yyyy"
//            } else {
//                dateFormatString = isTime ? "dd/MM, \(timeFormat)" : "dd/MM"
//            }
//
//        default:
//            let timeFormat: String = (isTime24 ? "HH:mm" : "hh:mm a")
//            if isYear {
//                dateFormatString = isTime ? "MMM dd yyyy, \(timeFormat)" : "MMM dd yyyy"
//            } else {
//                dateFormatString = isTime ? "MMM dd, \(timeFormat)" : "MMM dd"
//            }
//        }
//
//        return self.toString(timeZone: timeZone,
//                             format: dateFormatString,
//                             locale: Locale(identifier: lang))
//    }
}

// MARK: - DateFormatter
extension DateFormatter {
    func setFormatter(timeZone: TimeZone? = TimeZone.autoupdatingCurrent,
                      dateFormat: String = "yyyy-MM-dd HH:mm:ss",
                      locale: Locale? = Locale.current) {
        self.dateFormat = dateFormat
        self.calendar   = Calendar(identifier: .gregorian)
        if let setTimeZone = timeZone {
            self.timeZone = setTimeZone
        }
        if locale != nil {
            self.locale = locale
        }
    }

    func setKSTFormatter(dateFormat: String = "yyyy-MM-dd HH:mm:ss") {
        self.setFormatter(timeZone: TimeZone(abbreviation: "KST"),
                          dateFormat: dateFormat,
                          locale: Locale(identifier: "ko_kr"))
    }
}

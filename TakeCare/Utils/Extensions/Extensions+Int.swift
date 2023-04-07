//
//  Extensions+Int.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation

extension Int {
    // 국가별 자릿수 표기
    // https://velog.io/@baecheese?tag=iOS
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = .current
        let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        return formattedNumber ?? ""
    }

    // https://stackoverflow.com/questions/18267211/ios-convert-large-numbers-to-smaller-format
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor >= 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }

    var badgeAbbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = "%.0f%@"
            return accum ?? (factor >= 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }

    var abbreviatedLang: String {
        let abbrev = "천만BTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }

    var fanficAbbreviated: String {
        let abbrev = "만"
        if self < 10000 {
            return "\(self.withCommas())"
        }
        let factor = Double(ceil(Double(self/100))) / 100
        let format = String(format: "%.1f", factor)
        return format + abbrev
    }
}

// MARK: - Int64
extension Int64 {

    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = .current
        let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        return formattedNumber ?? ""
    }

    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }

    var voteAbbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = "%.2f%@"
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
//        if let userLang = user?.USER_LANG {
//            switch userLang.lowercased() {
//            case "ko":
//                let abbrev = "천만억조경"
//                if self < 10000000 {
//                    return self.withCommas()
//                }
//                return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
//                    switch tuple.element {
//                    case "만":
//                        let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3 - 2)
//                        rmzDLog("factor: \(factor)")
//                        let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.2f%@")
//                        return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
//                    case "억":
//                        let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3 - 1)
//                        rmzDLog("factor: \(factor)")
//                        let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.2f%@")
//                        return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
//                    default:
//                        break
//                    }
//                    let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
//                    let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.2f%@")
//                    return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
//                    } ?? String(self)
//            default:
//                return self.abbreviated
//            }
//        }
//        return String(self)
    }
}

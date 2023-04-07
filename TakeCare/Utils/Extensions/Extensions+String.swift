//
//  Extensions+String.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

extension String {
    func dateChanger() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")
        let date =  dateFormatter.date(from: self)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date ?? Date())
        return dateStr
    }

    static let allLanguage = "ko-en-es-ja-zh-zhtw-id-vi"
    // notaTODO: String to Html
    // https://medium.com/@valv0/a-swift-extension-for-string-and-html-8cfb7477a510
    var html2Attributed: NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return NSAttributedString(string: self)
        }
        return try? NSAttributedString(data: data,
                                      options: [.documentType: NSAttributedString.DocumentType.html,
                                                .characterEncoding: String.Encoding.utf8.rawValue],
                                      documentAttributes: nil)
    }

    var html2MutableAttributed: NSMutableAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return NSMutableAttributedString(string: self)
        }
        return try? NSMutableAttributedString(data: data,
                                              options: [.documentType: NSMutableAttributedString.DocumentType.html,
                                                        .characterEncoding: String.Encoding.utf8.rawValue],
                                              documentAttributes: nil)
    }

    // html 태그 제거 + html entity들 디코딩. (https://eunjin3786.tistory.com/138)
    var htmlEscaped: String {
        guard let encodedData = self.data(using: .utf8) else {
            return self
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        do {
            let attributed = try NSAttributedString(data: encodedData,
                                                    options: options,
                                                    documentAttributes: nil)
            return attributed.string
        } catch {
            return self
        }
    }

    func getRange(text: String) -> NSRange {
        let range = (self as NSString).range(of: text)
        return range
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return ceil(boundingBox.width)
    }

    func urlEncodedStirng(encoding: CFStringEncoding) -> String? {
        let queryKVSet = CharacterSet(charactersIn: ":/?&=;+!@#$()',*").inverted
        return self.addingPercentEncoding(withAllowedCharacters: queryKVSet)
    }

    // 자릿수 제거
    // https://velog.io/@baecheese
    var convertToLocaleCurrencyFormat: Int {
        return Int(self.replaceToPureNumber)
    }

    var replaceToPureNumber: Double {
        let groupingSeparator = NumberFormatter().groupingSeparator ?? ""// 천단위 기호
        let decimalSeparator = NumberFormatter().decimalSeparator ?? ""// 소숫점 기호
        let valueString = self
        .replacingOccurrences(of: "[^\(decimalSeparator)\(groupingSeparator)0-9]", with: "", options: .regularExpression)
        .replacingOccurrences(of: groupingSeparator, with: "")
        .replacingOccurrences(of: decimalSeparator, with: ".")// 소숫점 기호를 .으로 변경
        return Double(valueString) ?? 0
    }

    public var stringTrim: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    static func == (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    static func < (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedAscending
    }

    static func <= (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedAscending || lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    static func > (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedDescending
    }

    static func >= (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedDescending || lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    func toDate(format: String, locale: Locale = Locale.current, timeZone: TimeZone = TimeZone.current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.setFormatter(timeZone: timeZone, dateFormat: format, locale: locale)
        return dateFormatter.date(from: self)
    }

    func maxLength(length: Int) -> String {
        var str = self
        let nsString = str as NSString
        if nsString.length >= length {
            str = nsString.substring(with:
                NSRange(
                    location: 0,
                    length: nsString.length > length ? length : nsString.length)
            )
        }
        return  str
    }

    var isEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x1F1E6...0x1F1FF, // Regional country flags
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
            127000...127600, // Various asian characters
            65024...65039, // Variation selector
            9100...9300, // Misc items
            8400...8447: // Combining Diacritical Marks for Symbols
                return true

            default: continue
            }
        }
        return false
    }
}

// MARK: - StringProtocol
extension StringProtocol where Index == String.Index {
    func subString(after: String, before: String? = nil, options: String.CompareOptions = []) -> SubSequence? {
        guard let lowerBound = range(of: after, options: options)?.upperBound else { return nil }
        guard let before = before,
            let upperbound = self[lowerBound..<endIndex].range(of: before, options: options)?.lowerBound else {
                return self[lowerBound...]
        }
        return self[lowerBound..<upperbound]
    }
}

// MARK: - NSAttributedString
extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        return ceil(boundingBox.width)
    }
}

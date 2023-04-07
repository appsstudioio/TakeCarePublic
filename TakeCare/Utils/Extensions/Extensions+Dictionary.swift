//
//  Extensions+Dictionary.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation

extension Dictionary {
    func toString(divide: String = ", ") -> String {
        let str = (self.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }) as Array).joined(separator: divide)
        return str
    }

    func filterReturnString(key: String) -> String? {
        let value = self.filter {($0.key as? String == key)}.first?.value

        if value is String {
            guard let stringValue = value as? String else { return nil }
            return stringValue
        } else if value is Int {
            guard let intValue = value as? Int else { return nil }
            return "\(intValue)"
        } else if value is Double {
            guard let doubleValue = value as? Double else { return nil }
            return "\(doubleValue)"
        }

        return nil
    }
}

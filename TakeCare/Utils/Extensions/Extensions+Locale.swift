//
//  Extensions+Locale.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/05/06.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation

extension Locale {
    static var preferredLanguageIdentifier: String {
        let fromIdentifier = Locale.preferredLanguages.first!
        let comps = Locale.components(fromIdentifier: fromIdentifier)
        for lang in comps.values where lang != "GG" {
            return lang
        }
        return comps.values.first!
    }

    static var preferredLanguageLocalizedString: String {
        let fromIdentifier = Locale.preferredLanguages.first!
        return Locale.current.localizedString(forLanguageCode: fromIdentifier)!
    }
}

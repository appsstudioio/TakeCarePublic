//
//  RLMLocationSettingInfo.swift
//  TakeCare
//
//  Created by Lim on 31/07/2019.
//Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation
import RealmSwift

class RLMLocationSettingInfo: Object {
    @objc dynamic var idx: Int            = 0
    @objc dynamic var addressName: String = ""
    @objc dynamic var wgs84Lon: Double    = 0.0
    @objc dynamic var wgs84Lat: Double    = 0.0
    @objc dynamic var selectedFlag: Bool  = false
    @objc dynamic var regDate: Date       = Date()
    
    override static func primaryKey() -> String? {
        return "idx"
    }
    
    func autoIncrementID() -> Int {
        return (try! Realm().objects(RLMLocationSettingInfo.self).max(ofProperty: "idx") as Int? ?? 0) + 1
    }
}

//
//  UserDefaultControllers.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation
import SwiftUI

let userDefaultDistanceKey: String             = "appSettingDistanceKey"
let userDefaultPerPageKey: String              = "appSettingPerPageKey"
let userDefaultHospOpenFlagKey: String         = "appSettingHospOpenFlagKey"
let userDefaultLocationIndexKey: String        = "appSettingLocationIndexKey"
let userDefaultInterstitialADCntKey: String    = "interstitialADCnt"
let userDefaultRwardADCntKey: String           = "rewardADCnt"
let userDefaultAppStoreReviewKey: String       = "appStoreReviewFlagKey"
let userDefaultAppLocalNotificationKey: String = "appLocalNotificationFlagKey"
let userDefaultWeatherReloadDateKey: String    = "weatherReloadDateKey"
let userDefaultWeatherDataKey: String          = "WeatherDataKey"

enum TipViewPopupKey: String {
    case locationAddViewTipFlag = "locationAddViewTipFlagKey"
    case hospViewTipFlag        = "hospViewTipFlagKey"
    case shareTipFlag           = "shareTipFlagKey"
}

let defaults = UserDefaults(suiteName: globalAppGroupsKey)!

func getAppSettingDistance() -> Int {
    if defaults.integer(forKey: userDefaultDistanceKey) != 0 {
        return defaults.integer(forKey: userDefaultDistanceKey)
    }
    saveAppSettingDistance(distance: 10)
    return 10
}

func saveAppSettingDistance(distance: Int) {
    AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "DistanceSetting", itemName: "반경설정", contentType: "Modify")
    defaults.set(distance, forKey: userDefaultDistanceKey)
}

func getAppSettingPerPage() -> Int {
    if defaults.integer(forKey: userDefaultPerPageKey) != 0 {
        return defaults.integer(forKey: userDefaultPerPageKey)
    }
    saveAppSettingPerPage(perPage: 30)
    return 30
}

func saveAppSettingPerPage(perPage: Int) {
    AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "PerPageSetting", itemName: "목록갯수설정", contentType: "Modify")
    defaults.set(perPage, forKey: userDefaultPerPageKey)
}

func getAppSettingLocationIndex() -> Int {
    return defaults.integer(forKey: userDefaultLocationIndexKey)
}

func saveAppSettingLocationIndex(indexValue: Int) {
    defaults.set(indexValue, forKey: userDefaultLocationIndexKey)
}

func getAppSettingHospOpenFlag() -> Bool {
    return defaults.bool(forKey: userDefaultHospOpenFlagKey)
}

func saveAppSettingHospOpenFlag(flag: Bool) {
    AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "HospOpenSetting", itemName: "운영중인병원설정", contentType: "Modify")
    defaults.set(flag, forKey: userDefaultHospOpenFlagKey)
}

func getTipViewOpenFlag(keyName: TipViewPopupKey) -> Bool {
    return defaults.bool(forKey: keyName.rawValue)
}

func saveTipViewOpenFlag(keyName: TipViewPopupKey, flag: Bool) {
    defaults.set(flag, forKey: keyName.rawValue)
}

func getAdCountValue(keyName: String) -> Int {
    return defaults.integer(forKey: keyName)
}

func saveAdCountValue(keyName: String, cnt: Int) {
    defaults.set(cnt, forKey: keyName)
}

func getAppStoreReviewCheck() -> String {
    if let value = defaults.string(forKey: userDefaultAppStoreReviewKey){
        return value
    } else {
        return ""
    }
}

func saveAppStoreReviewCheck(value: String) {
    AnalyticsManager.shared.screenName(screenName: "앱스토어 리뷰 작성 화면", screenClass: "SKStoreReview")
    defaults.set(value, forKey: userDefaultAppStoreReviewKey)
}

func getAppLocalNotification() -> String {
    if let value = defaults.string(forKey: userDefaultAppLocalNotificationKey) {
        return value
    } else {
        return ""
    }
}

func saveAppLocalNotification(value: String) {
    defaults.set(value, forKey: userDefaultAppLocalNotificationKey)

}

func getWeatherReloadDate() -> Date? {
    if let value = defaults.string(forKey: userDefaultWeatherReloadDateKey) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        return dateFormatter.date(from: value)!
    } else {
        return Date()
    }
}

func saveWeatherReloadDate(value: Date) {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
    defaults.set(dateFormatter.string(from: value), forKey: userDefaultWeatherReloadDateKey)

}

func getWeatherData() -> [String: Any]? {
    if let data = defaults.object(forKey: userDefaultWeatherDataKey) as? Data {
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        return jsonData
    } else {
        return nil
    }
}


func saveWeatherData(data: Data) {
    defaults.set(data, forKey: userDefaultWeatherDataKey)
}

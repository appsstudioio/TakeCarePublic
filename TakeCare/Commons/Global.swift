//
//  Global.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import Foundation
@_exported import RealmSwift
@_exported import AdFitSDK
@_exported import Moya
@_exported import SwiftIcons
@_exported import MMBAlertsPickers
@_exported import Kingfisher

#if DEBUG
func DLog(_ message: Any? = "", showTime: Bool = false, file: String = #file, funcName: String = #function, line: Int = #line) {
    let fileName: String = (file as NSString).lastPathComponent
    var fullMessage = "\(fileName) -> \(funcName) -> \(line): \(String(describing: message))\n"
    
    if true == showTime {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy.MM.dd KK:mm:ss.SSS"
        let timeStr = dateFormatter.string(from: Date())
        fullMessage = "\(timeStr): " + fullMessage
    }
    
    print(fullMessage)
}

#else
func DLog(_ message: Any? = "", showTime: Bool = false, file: String = #file, funcName: String = #function, line: Int = #line) {
    
}
#endif
var globalAppIdentifierPrefix: String {
    let appIdentifierPrefix = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as? String
    return appIdentifierPrefix ?? ""
}

#if DEBUG
let globalAppGroupsKey: String = "group.io.appsstudio.TakeCareDevelop"
let globalKeychainSharingKey: String = globalAppIdentifierPrefix + "keychain.io.appsstudio.TakeCareDevelop"
#else
let globalAppGroupsKey: String = "group.io.appsstudio.TakeCare"
let globalKeychainSharingKey: String = globalAppIdentifierPrefix + "keychain.io.appsstudio.TakeCare"
#endif

let globalDynamicLinksDomainURIPrefix: String = "https://appsstudio.page.link"
let globalDynamicLinksCustomURLScheme: String = "io.appsstudio.TakeCare"

let globalUserDefaultAdCnt: Int = 1
let globalWeatherServiceKey: String = "ServiceKeys"

let globalBackBtImage = UIImage(named: "leftArrow")!.withRenderingMode(.alwaysTemplate)
let globalBackBtEdgeInsets = UIEdgeInsets(top: 2.5, left: -5, bottom: 2.5, right: 0)
var globalDistance                 = 10
var globalLocationIndex            = 0
var globalOpenHospFlag             = false
var globalLocationChangeReloadTab1 = false
var globalLocationChangeReloadTab2 = false

var globalAppInfo: [AppInfo] = []
var shareJsonData: Any?      = nil
var shareType: String        = ""

var globalLon: String = ""
var globalLat: String = ""

enum MoreMenuName {
    case appInfo, appSetting, babyProfile
}

enum MoreSubMenuName {
    case devBlog, qnaMail, openSource, versionInfo, policy, distanceSetting, perPageSetting, openHospSetting, alarmSetting
}

enum CareMenuName: String {
    case briefing    = "오늘의 브리핑"
    case schedule    = "%@ 일정"
    case dayWeather  = "%@ 날씨"
    case timeWeather = "시간별 날씨"
    case dustInfo    = "대기환경지수"
}

enum DustInfoType {
   case so2
   case o3
   case co
   case no2
   case pm10
   case pm25
}

enum DustLevelValue: Int {
    case level1 = 1, level2 = 2, level3 = 3, level4 = 4, level5 = 5, level6 = 6, level7 = 7
}

enum ApiLevelValue: Int {
    case level1 = 1, level2 = 2, level3 = 3, level4 = 4, level5 = 5
}

enum UserLocalNotificationType: String {
    case dailyReport = "DailyReport"
    case scheduleAlarm = "ScheduleAlarm"
}

struct UserLocalNotificationList {
    let list: [UserLocalNotificationType] = [.dailyReport, .scheduleAlarm]
    
    func getTitleName(type: UserLocalNotificationType) -> String {
        switch type {
            case .dailyReport:
                return "일일 알림"
            case .scheduleAlarm:
                return "일정 알림"
        }
    }
}

// AppTrackingTransparency 허용 여부
enum AppTrackingTransparencyStatus: UInt {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
}

struct AppColorList {
    let dustColorNomalLevel1    = UIColor(named: "dustColorNomalLevel1")!
    let dustColorNomalLevel2    = UIColor(named: "dustColorNomalLevel2")!
    let dustColorNomalLevel3    = UIColor(named: "dustColorNomalLevel3")!
    let dustColorNomalLevel4    = UIColor(named: "dustColorNomalLevel4")!
    let dustColorNomalLevel5    = UIColor(named: "dustColorNomalLevel5")!
    let dustColorNomalLevel6    = UIColor(named: "dustColorNomalLevel6")!
    let dustColorNomalLevel7    = UIColor(named: "dustColorNomalLevel7")!
    let dustColorSelectLevel1   = UIColor(named: "dustColorSelectLevel1")!
    let dustColorSelectLevel2   = UIColor(named: "dustColorSelectLevel2")!
    let dustColorSelectLevel3   = UIColor(named: "dustColorSelectLevel3")!
    let dustColorSelectLevel4   = UIColor(named: "dustColorSelectLevel4")!
    let dustColorSelectLevel5   = UIColor(named: "dustColorSelectLevel5")!
    let dustColorSelectLevel6   = UIColor(named: "dustColorSelectLevel6")!
    let dustColorSelectLevel7   = UIColor(named: "dustColorSelectLevel7")!
    let openHospColor           = UIColor(named: "openHospColor")!
    let openHospTextColor       = UIColor(named: "openHospTextColor")!
    let closeHospColor          = UIColor(named: "closeHospColor")!
    let closeHospTextColor      = UIColor(named: "closeHospTextColor")!
    let locationColor           = UIColor(named: "locationColor")!
    let weatherTempMaxColor     = UIColor(named: "weatherTempMaxColor")!
    let weatherTempMinColor     = UIColor(named: "weatherTempMinColor")!
    let weatherValueLevel1      = UIColor(named: "weatherValueLevel1")!
    let weatherValueLevel2      = UIColor(named: "weatherValueLevel2")!
    let weatherValueLevel3      = UIColor(named: "weatherValueLevel3")!
    let weatherValueLevel4      = UIColor(named: "weatherValueLevel4")!
    let weatherValueLevel5      = UIColor(named: "weatherValueLevel5")!
    let greenCustomColor        = UIColor(named: "greenCustomColor")!
    let lineClearColor          = UIColor(named: "lineClearColor")!
    let lineColor               = UIColor(named: "lineColor")!
    let naviBgColor             = UIColor(named: "naviBgColor")!
    let naviTitleColor          = UIColor(named: "naviTitleColor")!
    let tabBarBgColor           = UIColor(named: "tabBarBgColor")!
    let tabBarNormalColor       = UIColor(named: "tabBarNormalColor")!
    let tabBarSelectColor       = UIColor(named: "tabBarSelectColor")!
    let tableBgColor            = UIColor(named: "tableBgColor")!
    let tableCellBgColor        = UIColor(named: "tableCellBgColor")!
    let textColorDarkGray       = UIColor(named: "textColorDarkGray")!
    let textColorDarkText       = UIColor(named: "textColorDarkText")!
    let textColorLightGray      = UIColor(named: "textColorLightGray")!
    let textColorWhite          = UIColor(named: "textColorWhite")!
    let timeLineColor           = UIColor(named: "timeLineColor")!
    let bananaYellow            = UIColor(named: "bananaYellow")!
    let graphBgColor            = UIColor(named: "graphBgColor")!
    let greenColor              = UIColor(named: "greenColor")!
    let redColor                = UIColor(named: "redColor")!
    let detailViewBgColor       = UIColor(named: "detailViewBgColor")!
    let weatherAngryCloudyColor = UIColor(named: "weatherAngryCloudyColor")!
    let weatherClearColor       = UIColor(named: "weatherClearColor")!
    let weatherCloudyColor      = UIColor(named: "weatherCloudyColor")!
    let weatherRainColor        = UIColor(named: "weatherRainColor")!
    let boyMainColor            = UIColor(named: "boyMainColor")!
    let girlMainColor           = UIColor(named: "girlMainColor")!
    let helpBgColor             = UIColor(named: "helpBgColor")!
    let tooltipBgColor          = UIColor(named: "tooltipBgColor")!
    let tooltipTextColor        = UIColor(named: "tooltipTextColor")!
    let tooltipBorderColor      = UIColor(named: "tooltipBorderColor")!
    let toastBgColor            = UIColor(named: "toastBgColor")!
    let skeletonStartPointColor = UIColor(named: "skeletonStartPointColor")!
    let skeletonEndPointColor   = UIColor(named: "skeletonEndPointColor")!
}

let globalLoadingViewTag        = 0xAAAA

func setRealmConfig () {
    guard var fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: globalAppGroupsKey) else {
        DLog("Container URL is nil")
        return
    }
    fileURL.appendPathComponent("default.realm")
    Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: fileURL)
}

func deleteRealmDataBase () {
    autoreleasepool {
        // all Realm usage here
    }
    guard var realmURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: globalAppGroupsKey) else {
        DLog("Container URL is nil")
        return
    }
    realmURL.appendPathComponent("default.realm")
    let realmURLs = [
        realmURL,
        realmURL.appendingPathExtension("lock"),
        realmURL.appendingPathExtension("note"),
        realmURL.appendingPathExtension("management")
    ]
    for URL in realmURLs {
        do {
            try FileManager.default.removeItem(at: URL)
        } catch {
            // handle error
            DLog("Realm Delete Error")
        }
    }
}

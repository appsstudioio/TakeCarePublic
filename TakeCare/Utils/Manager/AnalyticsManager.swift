//
//  AnalyticsManager.swift
//  TakeCare
//
//  Created by DONGJU LIM on 28/08/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAnalytics

class AnalyticsManager: NSObject {
    enum AnalyticsEventLogType {
        case join_group, login, search, select_content, share, sign_up
    }
    
    enum UserPropertyType: String {
        case distance_setting = "distance_setting"
        case perpage_setting  = "perpage_setting"
        case openhosp_setting = "openhosp_setting"
        case location_setting = "location_setting"
    }
    
    static let shared: AnalyticsManager = {
        var instance = AnalyticsManager()
        return instance
    }()
    
    /*
     // 이벤트 로그
     join_group : 사용자가 그룹에 참여할 때. 다양한 집단이나 사용자 그룹의 인기도를 추적할 수 있습니다. (group_id)
     login : 사용자가 로그인할 때 (method)
     search : 사용자가 앱에서 검색할 때 (search_term)
     select_content : 사용자가 앱에서 콘텐츠를 선택할 때 (content_type, item_id)
     share : 사용자가 앱에서 콘텐츠를 공유했을 때 (content_type, item_id)
     sign_up : 사용자가 가입했을 때. 가장 많이 사용된 가입 방법(예: Google 계정, 이메일 주소 등)이 무엇인지 확인할 수 있습니다. (method)
     */
    func eventLoging(logType: AnalyticsEventLogType, itemID: String, itemName: String = "", contentType: String = "" ) {
    #if RELEASE
        switch logType {
        case .join_group:
            Analytics.logEvent(AnalyticsEventJoinGroup, parameters: [
                AnalyticsParameterGroupID: "id-\(itemID)",
                AnalyticsParameterItemName: itemName
            ])
            break
        case .login:
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                AnalyticsParameterMethod: itemID
            ])
            break
        case .search:
            Analytics.logEvent(AnalyticsEventSearch, parameters: [
                AnalyticsParameterSearchTerm: itemID
            ])
            break
        case .select_content:
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-\(itemID)",
                AnalyticsParameterItemName: itemName,
                AnalyticsParameterContentType: contentType
                ])
            break
        case .share:
            Analytics.logEvent(AnalyticsEventShare, parameters: [
                AnalyticsParameterItemID: "id-\(itemID)",
                AnalyticsParameterItemName: itemName,
                AnalyticsParameterContentType: contentType
                ])
            break
        case .sign_up:
            Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                AnalyticsParameterSignUpMethod: itemID
                ])
            break
        }
    #endif
    }
    func eventCustomLoging(eventName: String, parameters:[String: NSObject]) {
    #if RELEASE
        Analytics.logEvent(eventName, parameters: parameters)
    #endif
    }
    // 화면 기록
    func screenName(screenName: String, screenClass: String) {
        // These strings must be <= 36 characters long in order for setScreenName:screenClass: to succeed.
        // [START set_current_screen]
    #if RELEASE
        let parameters = [AnalyticsParameterScreenName: screenName, AnalyticsParameterScreenClass: screenClass]
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: parameters)
    #endif
        // [END set_current_screen]
    }
    // 사용자 속성, 설정값 추적
    func userProperty(value: String, type: UserPropertyType) {
        // [START user_property]
    #if RELEASE
        Analytics.setUserProperty(value, forName: type.rawValue)
    #endif
        // [END user_property]
    }
}

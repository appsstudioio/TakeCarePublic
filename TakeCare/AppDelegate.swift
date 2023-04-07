//
//  AppDelegate.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCrashlytics
import GoogleMaps
import EasyTipView
import Toast_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = globalDynamicLinksCustomURLScheme
        FirebaseApp.configure()
        DynamicLinks.performDiagnostics(completion: nil)
        
        // 광고 리셋
        saveAdCountValue(keyName: userDefaultInterstitialADCntKey, cnt: globalUserDefaultAdCnt)
        
        #if false
        /* Kingfisher Image Cache config */
        // Limit memory cache size to 300 MB.(300 * 1024 * 1024)
        ImageCache.default.memoryStorage.config.totalCostLimit = 1 * 1024 * 1024
        // Limit memory cache to hold 1 images at most.
        ImageCache.default.memoryStorage.config.countLimit = 1
        // Limit disk cache size to 1 GB.
        ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
        // Memory image expires after 1 minutes.
        ImageCache.default.memoryStorage.config.expiration = .seconds(60)
        // Disk image never expires.
        ImageCache.default.diskStorage.config.expiration = .never
        
        ImageCache.default.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                DLog("======= Disk cache size: \(Double(size) / 1024 / 1024) MB")
            case .failure(let error):
                DLog(error)
            }
        }
        #endif
        
        DLog("======== App UUID String : \(AppInfoManager.shared.deviceUUID ?? "")")
        GMSServices.provideAPIKey("GMSServiceKey")
        
        RemoteConfigManager.shared.setupRemoteConfig()
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = AppColorList().tooltipBgColor
        preferences.drawing.foregroundColor = AppColorList().tooltipTextColor
        preferences.drawing.borderWidth = 1
        preferences.drawing.borderColor = AppColorList().tooltipBorderColor
        preferences.drawing.textAlignment = NSTextAlignment.center
        preferences.drawing.font = UIFont(fontsStyle: .regular, size: 12)
        preferences.positioning.maxWidth = 300
        EasyTipView.globalPreferences = preferences
        
        // toggle "tap to dismiss" functionality
        ToastManager.shared.isTapToDismissEnabled = true
        // toggle queueing behavior
        ToastManager.shared.isQueueEnabled = true
        var style = ToastStyle()
        style.titleColor          = AppColorList().textColorWhite
        style.messageColor        = AppColorList().textColorWhite
        style.backgroundColor     = AppColorList().toastBgColor
        style.titleFont           = UIFont(fontsStyle: .bold, size: 14)
        style.messageFont         = UIFont(fontsStyle: .regular, size: 13)
        style.displayShadow       = false
        ToastManager.shared.style = style
        
        /* 앱 설정값 불러오기 */
        globalDistance      = getAppSettingDistance()
        globalLocationIndex = getAppSettingLocationIndex()
        globalOpenHospFlag  = getAppSettingHospOpenFlag()
        
        AnalyticsManager.shared.userProperty(value: String(format: "%d", globalDistance), type: .distance_setting)
        AnalyticsManager.shared.userProperty(value: (globalOpenHospFlag == true ? "운영" : "전체"), type: .location_setting)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // [START openurl]
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        DLog("i Received a URL Through a custom URL Scheme \(url.absoluteString)")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            handleDynamicLink(dynamicLink)
            //            DLog("url \(url)")
            return true
        }

        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // [START_EXCLUDE]
            // In this sample, we just open an alert.
            handleDynamicLink(dynamicLink)
            // [END_EXCLUDE]
            return true
        }
        // [START_EXCLUDE silent]
        // Show the deep link that the app was called with.
        showDeepLinkAlertView(withMessage: "openURL:\n\(url)")
        // [END_EXCLUDE]
        return false
    }
    // [END openurl]
    @available(iOS 8.0, *)
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if let inComingUrl = userActivity.webpageURL {
            let handled = DynamicLinks.dynamicLinks().handleUniversalLink(inComingUrl) { (dynamiclink, error) in
                DLog("dynamiclink \(String(describing: dynamiclink))")
                guard error == nil else {
                    DLog("Found Error \(String(describing: error?.localizedDescription))")
                    return
                }

                if let dynamicLink = dynamiclink {
                    self.handleDynamicLink(dynamicLink)
                }
            }
            if !handled {
                // Show the deep link URL from userActivity.
                let message = "continueUserActivity webPageURL:\n\(userActivity.webpageURL?.absoluteString ?? "")"
                showDeepLinkAlertView(withMessage: message)
            }
            return handled
        }
        return false
    }

    @available(iOS 8.0, *)
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        DLog("======== userActivityType :: \(userActivityType) // error :: \(error.localizedDescription)")
    }
    
    func handleDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            DLog("That's weird. My Dynamic link object has no url")
            return
        }
        DLog("My incoming link parameter is \(url.absoluteString)")
        
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        let hpid = queryItems?.filter({$0.name == "hpid"}).first
        let type = queryItems?.filter({$0.name == "type"}).first
        DLog("hpid -> \(String(describing: hpid)) :: type -> \(String(describing: type))")
        guard type?.value != nil && hpid?.value != nil else { return }
        if let vc = UIApplication.topViewController() {
            toastView(view: vc.view, message: "공유기능은 지원하지 않습니다.", duration: 3.0, position: .bottom, title: nil)
        }
    }
    
    func showDeepLinkAlertView(withMessage message: String) {
        if let viewController = UIApplication.topViewController() {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let alertController = UIAlertController(title: "Deep-link Data", message: message, preferredStyle: .alert)
            alertController.addAction(okAction)
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let type: UserLocalNotificationType = UserLocalNotificationType(rawValue: response.actionIdentifier) else { return }
        switch type {
            case .dailyReport:
                DLog("일일 알림")
            case .scheduleAlarm:
                DLog("일정 알림")
        }
    }

    func requestLocalNotification() {
        if UserLocalNotificationList().list.count > 0 {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge],
                                                                    completionHandler: { (authorized, error) in
                if !authorized {
                    DLog("App is useless becase you did not allow notification")
                }
            })

            var listArray: [UNNotificationAction] = []
            for obj in UserLocalNotificationList().list {
                listArray.append(UNNotificationAction(identifier: obj.rawValue,
                                                      title: UserLocalNotificationList().getTitleName(type: obj),
                                                      options: []))
            }
            let category = UNNotificationCategory(identifier: "TakeLocalAlarmCategory",
                                                  actions: listArray,
                                                  intentIdentifiers: [],
                                                  options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            UNUserNotificationCenter.current().delegate = self
        }
    }

    func settingLocalNotification(type: UserLocalNotificationType, title: String, message: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "TakeLocalAlarmCategory"
        
        switch type {
            case .dailyReport:
                //Daily
                let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
                let request = UNNotificationRequest(identifier: type.rawValue, content: content, trigger: trigger)
                self.removeLocalNotification(type: type)
                UNUserNotificationCenter.current().add(request){ (error) in
                    if let error = error {
                        DLog("Notification Add Error:\(error.localizedDescription)")
                    }
                }
            case .scheduleAlarm:
                //Date
                let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,repeats: false)
                let request = UNNotificationRequest(identifier: type.rawValue, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request){ (error) in
                    if let error = error {
                        DLog("Notification Add Error:\(error.localizedDescription)")
                    }
                }
        }
    }
    
    func removeLocalNotification(type: UserLocalNotificationType?) {
        guard let notiType = type else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            return
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notiType.rawValue])
    }
}

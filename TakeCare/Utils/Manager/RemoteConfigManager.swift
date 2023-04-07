//
//  RemoteConfigManager.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2020/01/23.
//  Copyright © 2020 com. All rights reserved.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

// Google Firebase Remote Config Model
class RemoteConfigManager: NSObject {
    var remoteConfig: RemoteConfig!
    let appInformationDataConfigKey = "app_information_data"
    var appConfigList: AppConfigData? {
        get {
            if let jsonData = UserDefaults.standard.object(forKey: self.appInformationDataConfigKey) as? Dictionary<String, Any> {
                guard let datas = try? JSONSerialization.data(withJSONObject: jsonData) else { return nil }
                return try? JSONDecoder().decode(AppConfigData.self, from: datas)
            } else {
                self.fetchConfig()
                return nil
            }
        }
    }
    let expirationDuration = 3600

    static let shared: RemoteConfigManager = {
        var instance = RemoteConfigManager()
        instance.remoteConfig = RemoteConfig.remoteConfig()
        return instance
    }()

    func setupRemoteConfig() {
        // Create a Remote Config Setting to enable developer mode, which you can use to increase
        // the number of fetches available per hour during development. See Best Practices in the
        // README for more information.
        // [START enable_dev_mode]
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        // [END enable_dev_mode]

        // Set default Remote Config parameter values. An app uses the in-app default values, and
        // when you need to adjust those defaults, you set an updated value for only the values you
        // want to change in the Firebase console. See Best Practices in the README for more
        // information.
        // [START set_default_values]
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        // [END set_default_values]
        fetchConfig()
    }

    func fetchConfig() {
        // [START fetch_config_with_callback]
        // TimeInterval is set to expirationDuration here, indicating the next fetch request will use
        // data fetched from the Remote Config service, rather than cached parameter values, if cached
        // parameter values are more than expirationDuration seconds old. See Best Practices in the
        // README for more information.
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                DLog("Config fetched!")
                self.remoteConfig.fetchAndActivate { (status, error) in
                    DLog("=== Status :: \(status)  Config fetched! Error: \(error?.localizedDescription ?? "No error available.")")
                }
            } else {
                DLog("Config not fetched")
                DLog("Error: \(error?.localizedDescription ?? "No error available.")")
            }

            if let jsonData = self.remoteConfig[self.appInformationDataConfigKey].jsonValue {
                DLog("=== Remote Config Data :: \(jsonData)")
                UserDefaults.standard.set(jsonData, forKey: self.appInformationDataConfigKey)
            }
        }
      // [END fetch_config_with_callback]
    }

    func checkAppUpdate(vc: UIViewController) {
        if let data = self.appConfigList {
            // 앱 강제 업데이트 체크..
            if data.fiexedUpdateVersion >= AppInfoManager.shared.appCurrentVersion && data.fiexedUpdateFlag == true {
                let alert = UIAlertController(title: NSLocalizedString("appupdate_title", comment: "알림"),
                                              message: appConfigList?.fiexedUpdateMsg,
                                              preferredStyle: .alert)
                let title = NSLocalizedString("appupdate_okkey", comment: "업데이트")
                let okAction = UIAlertAction(title: title, style: .default, handler: { action in
                    //do something when click button
                    if let url = URL(string: data.verInfo!.appStoreUrl) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                })
                alert.addAction(okAction)
                vc.present(alert, animated: true)
            }
        }
    }
}

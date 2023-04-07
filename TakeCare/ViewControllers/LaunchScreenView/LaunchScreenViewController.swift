//
//  LaunchScreenViewController.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class LaunchScreenViewController: UIViewController {
    @IBOutlet weak var launchMsgLabel: UILabel!
    @IBOutlet weak var launchTitleLabel: UILabel!

    // MARK: - variables
    var viewModel = CareViewModel()
    private func getWeatherData() {
        if globalLocationIndex == 0 {
            AnalyticsManager.shared.userProperty(value: "현재위치", type: .location_setting)
            launchMsgLabel.text = NSLocalizedString("location_access_msg", comment: "")
            AppInfoManager.shared.getUserLocation { (success) in
                if success {
                    DLog("위치정보 가져오기 성공!!!")
                } else {
                    DLog("위치정보 가져오기 실패!!!")
                    toastView(view: self.view, message: "위치를 가져오는데 실패하였습니다.\n기본 설정된 설정값을 사용합니다.", duration: 3.0, position: .bottom, title: nil)
                }
                globalLon = String(AppInfoManager.shared.currentLocation.longitude)
                globalLat = String(AppInfoManager.shared.currentLocation.latitude)
                self.viewModel.getWeatherData(query: .forecast(query: "\(globalLat),\(globalLon)", days: "3"))
            }
        } else {
            let locationData = try! Realm().objects(RLMLocationSettingInfo.self).filter("idx = %d", globalLocationIndex)
            if locationData.count > 0 {
                globalLon = "\(locationData[0].wgs84Lon)"
                globalLat = "\(locationData[0].wgs84Lat)"
                AnalyticsManager.shared.userProperty(value: locationData[0].addressName, type: .location_setting)
            } else {
                // 예외 처리...
                globalLon = String(AppInfoManager.shared.currentLocation.longitude)
                globalLat = String(AppInfoManager.shared.currentLocation.latitude)
            }
            self.viewModel.getWeatherData(query: .forecast(query: "\(globalLat),\(globalLon)", days: "3"))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        launchMsgLabel.text = NSLocalizedString("check_network", comment: "")
        if AppInfoManager.shared.isNetworkReachable() == true {
            if AppInfoManager.shared.isNetworkReachableOnEthernetOrWiFi() == false {
                toastView(view: self.view, message: "WiFi에 연결하지 않으면 사용자 요금제에 따라 데이터 통화료가 발생할 수 있습니다.")
            }
            
            RemoteConfigManager.shared.setupRemoteConfig()
            // 아이 일정 등록
            childAllVcnScheduleUpdate()
            AppInfoManager.shared.appTrackingTransparencyCheck { status in
                self.getWeatherData()
            }
        } else{
            UIAlertController.showAlert("알림", NSLocalizedString("error_network", comment: ""), self, { (_) in
                self.dismiss(animated: true, completion: nil)
                exit(0);
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let attributes = strokeLabelText(font: UIFont(fontsStyle: .bold, size: 42.0),
                                         strokeWidth: 2,
                                         textColor: UIColor(named: "IntroTextColor")!,
                                         strokeColor: AppColorList().textColorDarkText)
        launchTitleLabel.attributedText = NSMutableAttributedString(string: NSLocalizedString("launch_title", comment: ""),
                                                                    attributes: attributes)
        // Realm Database File Delete
        // deleteRealmDataBase()
        // Realm Database File 설정
        setRealmConfig()
        
        if try! Realm().objects(RLMLocationSettingInfo.self).count == 0 {
            // 위치가 저장된 데이터가 없으면 현재 위치가 기본값이 됨.... 최초 실행시...
            saveAppSettingLocationIndex(indexValue: 0)
            globalLocationIndex = 0
        }
        
        AnalyticsManager.shared.screenName(screenName: "인트로화면", screenClass: "LaunchScreenView")
        AnalyticsManager.shared.eventLoging(logType: .login, itemID: "not_login")

        setViewModel()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - functions
    private func setViewModel() {
        viewModel.onWeatherUpdate = { status in
            self.callHomeView()
        }
    }

    func callHomeView() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let mainTabBar = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarControllerSID") as! MainTabBarController
            appDelegate.window?.rootViewController = mainTabBar
        }
    }
}

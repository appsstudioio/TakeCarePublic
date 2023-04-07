//
//  AppInfoManager.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/11/12.
//

import Foundation
import AppTrackingTransparency
import AdSupport
import UIKit
import CoreLocation
import Alamofire

class AppInfoManager: NSObject {
    public typealias BasicCallback = (Bool) -> Void

    var appCurrentVersion: String {
        if let infomation = Bundle.main.infoDictionary,
           let appVersion = infomation["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "1.0.0"
    }
    var osVersion: String? {
        return UIDevice.current.systemVersion
    }
    var appBundleID: String {
        if let infomation = Bundle.main.infoDictionary,
           let appVersion = infomation["CFBundleIdentifier"] as? String {
            return appVersion
        }
        return "1.0.0"
    }
    var deviceUUID: String? {
        if let uuidString = KeyChainManager.shared.string(forKey: .uuid) {
            return uuidString
        } else {
            guard let deviceID = UIDevice.current.identifierForVendor?.uuidString.replacingOccurrences(of: "-", with: "") else {
                return nil
            }
            KeyChainManager.shared.set(deviceID, forKey: .uuid)
            return deviceID
        }
    }

    var locationManager: CLLocationManager? = nil
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var gpsUpdateCompletionBlock: BasicCallback?

    override init() {
        locationManager = CLLocationManager()
        currentLocation = CLLocationCoordinate2D(latitude: 37.49419280, longitude: 127.03442750)
    }

    static let shared: AppInfoManager = {
        var instance = AppInfoManager()
        return instance
    }()

    // MARK: - Network
    func isNetworkReachable() -> Bool {
        guard let manager = NetworkReachabilityManager(host: weatherAPIHostUrl) else { return false }
        return manager.isReachable
    }

    func isNetworkReachableOnWWAN() -> Bool {
        guard let manager = NetworkReachabilityManager(host: weatherAPIHostUrl) else { return false }
        return manager.isReachableOnCellular
    }

    func isNetworkReachableOnEthernetOrWiFi() -> Bool {
        guard let manager = NetworkReachabilityManager(host: weatherAPIHostUrl) else { return false }
        return manager.isReachableOnEthernetOrWiFi
    }

    // MARK: - Location
    func getUserLocation(_ gpsUpdateCompletionBlock: @escaping BasicCallback ) {
        self.gpsUpdateCompletionBlock = gpsUpdateCompletionBlock
        callLocationManager()
    }

    func callLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                DLog("No access : \(CLLocationManager.authorizationStatus())")
                if locationManager != nil {
                    locationManager?.delegate = self
                    // locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters

                    if (locationManager?.responds(to: #selector(self.requestWhenInUseAuthorization)))! {
                        locationManager?.requestWhenInUseAuthorization()
                    }
                    locationManager?.startUpdatingLocation()
                }
                break
            case .restricted, .denied:
                DLog("No access : \(CLLocationManager.authorizationStatus())")
                locationSettingAlertAndMoveToSettingApp()
                break
            case .authorizedAlways, .authorizedWhenInUse:
                DLog("Access")
                if locationManager != nil {
                    locationManager?.delegate = self
                    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                    //locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
                    //locationManager?.distanceFilter = 500

                    if (locationManager?.responds(to: #selector(self.requestWhenInUseAuthorization)))! {
                        locationManager?.requestWhenInUseAuthorization()
                    }
                    locationManager?.startUpdatingLocation()
                }
                break
            }
        } else {
            DLog("Location services are not enabled")
            locationSettingAlertAndMoveToSettingApp()
        }
    }

    @objc func requestWhenInUseAuthorization() {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()

        // If the status is denied or only granted for when in use, display an alert
        if status == .authorizedWhenInUse || status == .denied {
            locationSettingAlertAndMoveToSettingApp()
        } else if status == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        }
    }

    func locationSettingAlertAndMoveToSettingApp() {
        let alert = UIAlertController(title: NSLocalizedString("location_title", comment: "알림"),
                                      message: NSLocalizedString("location_message", comment: ""),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("location_okkey", comment: "설정 이동"), style: .default, handler: { action in
            //do something when click button
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                self.gpsUpdateCompletionBlock?(false)
            }
        })
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("location_cancel", comment: "취소"), style: .default, handler: { action in
            self.gpsUpdateCompletionBlock?(false)
        })
        alert.addAction(cancelAction)

        if let vc = UIApplication.shared.delegate?.window??.rootViewController {
            vc.present(alert, animated: true)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension AppInfoManager: CLLocationManagerDelegate {
    func didEndUpdateLocation() {
        if currentLocation.longitude == 0.00000 && currentLocation.latitude == 0.00000 {
            currentLocation.latitude = 37.49419280
            currentLocation.longitude = 127.03442750
        }
        locationManager?.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DLog("locationManager didFailWithError \(error.localizedDescription)")

        if currentLocation.longitude == 0 && currentLocation.latitude == 0 {
            currentLocation.latitude = 37.49419280
            currentLocation.longitude = 127.03442750
        }

        if gpsUpdateCompletionBlock != nil {
            gpsUpdateCompletionBlock?(false)
            gpsUpdateCompletionBlock = nil
        }

        didEndUpdateLocation()

    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { didEndUpdateLocation(); return }
        DLog("didUpdateLocations : \(location)")

        currentLocation.latitude = location.coordinate.latitude
        currentLocation.longitude = location.coordinate.longitude
        // 대한민국 지도에 관한 일반정보의 경도범위는 124 – 132, 위도범위는 33 – 43 이다.
        // 아이를 부탁해는 한국만 서비스 하기 때문에 위치를 한국으로 제한한다! -> 날씨 API 교체로 인해서 상관 없음..
//        if !(currentLocation.longitude > 124.0 && currentLocation.longitude < 132.0
//             && currentLocation.latitude > 33.0 && currentLocation.latitude < 43.0) {
//            currentLocation.latitude = 37.49419280
//            currentLocation.longitude = 127.03442750
//        }

        if gpsUpdateCompletionBlock != nil {
            gpsUpdateCompletionBlock?(true)
            gpsUpdateCompletionBlock = nil
        }

        didEndUpdateLocation()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DLog("didChangeAuthorizationStatus");
    }
}

// MARK: - CLLocationManagerDelegate
extension AppInfoManager {
    func getLocationAddress (location: CLLocationCoordinate2D, locationCompleteBlock :@escaping (String) -> Void) {
        var returnString: String = ""
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        geocoder.reverseGeocodeLocation(clLocation, preferredLocale: Locale(identifier: "ko_KR")) { (placeMarks, error) in
            if (error != nil) {
                DLog("reverseGeocodeLocation error : \(String(describing: error))")
                locationCompleteBlock("")
                return
            }

            if placeMarks!.count > 0, let placeMark: CLPlacemark = placeMarks?[0] {
//                if let administrativeArea = placeMark.administrativeArea {
//                   returnString = administrativeArea
//                }
                if let locality = placeMark.locality {
                    returnString = locality
                }
                if let thoroughfare = placeMark.thoroughfare {
                    returnString = returnString + " " + thoroughfare
                }
            }
            locationCompleteBlock(returnString)

        }
    }

    func getAddressLocation (address: String, locationCompleteBlock :@escaping ([CLPlacemark]?, Bool) -> Void) {
        let geocoder = CLGeocoder()
        if address.count > 2 {
            geocoder.geocodeAddressString(address, in: nil, preferredLocale: Locale(identifier: "ko_KR")) { (placeMarks, error) in
                if (error != nil) {
                    DLog("geocodeAddressString error : \(String(describing: error?.localizedDescription))")
                    locationCompleteBlock(nil, false)
                    return

                }

                if placeMarks!.count > 0 {
                   locationCompleteBlock(placeMarks, true)
                } else {
                   locationCompleteBlock(nil, false)
                }
            }
        } else {
            locationCompleteBlock(nil, false)
        }
    }

    func appTrackingTransparencyCheck(completionHandler: @escaping (AppTrackingTransparencyStatus) -> Void) {
        if #available(iOS 14.0, *) {
            // 사용자 추적 권한 동의 팝업 호출
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { (status) in
                // IDFA 추적 허용 체크
                guard let returnStatus = AppTrackingTransparencyStatus(rawValue: status.rawValue) else {
                    completionHandler(.denied)
                    return
                }
                completionHandler(returnStatus)
            })
        } else {
            completionHandler(.authorized)
        }
    }
}

//
//  Util.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//
import UIKit
import Foundation
import Toast_Swift
import Firebase
import CoreLocation
import Solar
import RealmSwift
import Lottie
import JavaScriptCore
import FirebaseDynamicLinks

func toastView(view: UIView,
               message: String,
               duration: TimeInterval = ToastManager.shared.duration,
               position: ToastPosition = ToastManager.shared.position,
               title: String? = nil) {

    // toast with a specific duration and position
    view.makeToast(message, duration: duration, position: position, title: title)
}

func getImageData(urlString : String) -> NSData? {
    guard let url = URL(string: urlString) else { return nil }
    if let data = NSData(contentsOf: url) {
        return data
    }
    else {
        return nil
    }
}

func strokeLabelText(font: UIFont, strokeWidth: Float, textColor: UIColor, strokeColor: UIColor) -> [NSAttributedString.Key: Any] {
    return [
        NSAttributedString.Key.strokeColor : strokeColor,
        NSAttributedString.Key.foregroundColor : textColor,
        NSAttributedString.Key.strokeWidth : -strokeWidth,
        NSAttributedString.Key.font : font
    ]
}

@IBDesignable
class PaddingLabel: UILabel {
    /// The amount of padding for each side in the label.
    @objc dynamic open var edgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            // This fixes an issue where the last line of the label would sometimes be cut off.
            if numberOfLines == 0 {
                let boundsWidth = bounds.width - edgeInsets.left - edgeInsets.right
                if preferredMaxLayoutWidth != boundsWidth {
                    preferredMaxLayoutWidth = boundsWidth
                    setNeedsUpdateConstraints()
                }
            }
        }
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInsets) )
        // super.drawText(in: UIEdgeInsetsInsetRect(rect, edgeInsets))
    }
    
    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width  += edgeInsets.left + edgeInsets.right
        size.height += edgeInsets.top + edgeInsets.bottom
        
        // There's a UIKit bug where the content size is sometimes one point to short. This hacks that.
        if numberOfLines == 0 { size.height += 1 }
        
        return size
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var parentSize = super.sizeThatFits(size)
        parentSize.width  += edgeInsets.left + edgeInsets.right
        parentSize.height += edgeInsets.top + edgeInsets.bottom
        
        return parentSize
    }
}

@IBDesignable
class CustomTextField: UITextField {
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 0
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset))
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset))
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
       return bounds.inset(by: UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset))
    }
}

/// A view who's `layerClass` is a `CAGradientLayer`.
@IBDesignable
class SkeletonGradientView: UIView {
    override open class var layerClass: AnyClass {
      return CAGradientLayer.self
    }

    /// A convenient way to access the `GradientView`'s corresponding `CAGradientLayer`.
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }

    /// A convenient way to slide the `GradientView`'s corresponding `CAGradientLayer`.
    func slide(group: ((CAAnimationGroup) -> Void) = { _ in }) {
        return gradientLayer.slide(group: group)
    }

    /// A convenient way to stop sliding the `GradientView`'s corresponding `CAGradientLayer`.
    func stopSliding() {
        return gradientLayer.stopSliding()
    }
}

var globalFanplusLoadingView: LoadingView?
func startAnimationIndicator() {
    guard let mainWindow = UIApplication.key else { return }

    if mainWindow.viewWithTag(globalLoadingViewTag) == nil {
        if globalFanplusLoadingView == nil {
            mainWindow.backgroundColor = UIColor.clear
            globalFanplusLoadingView = LoadingView(frame: UIScreen.main.bounds)
            globalFanplusLoadingView?.tag = globalLoadingViewTag
            mainWindow.addSubview(globalFanplusLoadingView!)
        }
    }
}

func stopAnimationIndicator() {
    if globalFanplusLoadingView != nil {
        globalFanplusLoadingView?.removeLoadingView()
        globalFanplusLoadingView = nil
    }

    guard let mainWindow = UIApplication.key else { return }
    if  let loadingView = mainWindow.viewWithTag(globalLoadingViewTag) as? LoadingView {
        loadingView.removeLoadingView()
    }
}

func buildDynamicLink(link: URL, title: String, descriptionText: String, imageURL: String, completionHandler: @escaping (URL?) -> Void) {
    guard let components = DynamicLinkComponents(link: link, domainURIPrefix: globalDynamicLinksDomainURIPrefix) else { return }
    
    // iOS params
    let iOSParams = DynamicLinkIOSParameters(bundleID: AppInfoManager.shared.appBundleID)
    iOSParams.appStoreID = "1471938305"
    iOSParams.customScheme = globalDynamicLinksCustomURLScheme
    iOSParams.minimumAppVersion = "1.0.2"
    components.iOSParameters = iOSParams
    
    // social tag params
    let socialParams = DynamicLinkSocialMetaTagParameters()
    socialParams.title = title
    socialParams.descriptionText = descriptionText
    if let imgUrl = URL(string: imageURL) {
        socialParams.imageURL = imgUrl
    }
    components.socialMetaTagParameters = socialParams
    
    let options = DynamicLinkComponentsOptions()
    options.pathLength = .unguessable
    components.options = options
    DLog(components.url?.absoluteString)
    
    components.shorten { (shortURL, warnings, error) in
        if let error = error {
            DLog(error.localizedDescription)
            completionHandler(nil)
            return
        }
        DLog(shortURL?.absoluteString ?? "")
        completionHandler(shortURL)
    }
}

func getCodeToIcon(code: Int) -> Int {
    switch code {
        case 1000: return 113
        case 1003: return 116
        case 1006: return 119
        case 1009: return 122
        case 1030: return 143
        case 1063: return 176
        case 1066: return 179
        case 1069: return 182
        case 1072: return 185
        case 1087: return 200
        case 1114: return 227
        case 1117: return 230
        case 1135: return 248
        case 1147: return 260
        case 1150: return 263
        case 1153: return 266
        case 1168: return 281
        case 1171: return 284
        case 1180: return 293
        case 1183: return 296
        case 1186: return 299
        case 1189: return 302
        case 1192: return 305
        case 1195: return 308
        case 1198: return 311
        case 1201: return 314
        case 1204: return 317
        case 1207: return 320
        case 1210: return 323
        case 1213: return 326
        case 1216: return 329
        case 1219: return 332
        case 1222: return 335
        case 1225: return 338
        case 1237: return 350
        case 1240: return 353
        case 1243: return 356
        case 1246: return 359
        case 1249: return 362
        case 1252: return 365
        case 1255: return 368
        case 1258: return 371
        case 1261: return 374
        case 1264: return 377
        case 1273: return 386
        case 1276: return 389
        case 1279: return 392
        case 1282: return 395
        default:
            return 113
    }
}

func getWeatherIcon(code: Int, isDay: Int) -> String {
    // ""
    let iconCode = getCodeToIcon(code: code)
    let type = (isDay == 0 ? "night" : "day")
    return "https://cdn.weatherapi.com/weather/128x128/\(type)/\(iconCode).png"
}

//func getCurrentWeatherIconName(ptyCode: PTYCodeType, skyCode: SKYCodeType, latitude: Double, longitude: Double, date: Date) -> String {
//    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    let solar = Solar(for: date, coordinate: location)
//    var returnName: String = "sunAlt"
//    if ptyCode == .none {
//        switch skyCode {
//        case .clear:
//            returnName = "sunAlt"
//            if solar!.isNighttime {
//                returnName = "night"
//            }
//            break
//        case .cloudy:
//            returnName = "cloudy"
//            if solar!.isNighttime {
//                returnName = "cloudyNight"
//            }
//            break
//        case .angryCloudy:
//            returnName = "cloudy"
//            break
//        case .overcast:
//            returnName = "cloudy"
//            if solar!.isNighttime {
//                returnName = "cloudyNight"
//            }
//            break
//        default:
//            break
//        }
//    } else if ptyCode == .rain {
//        returnName = "rainySunny"
//        if solar!.isNighttime {
//            returnName = "rainyNight"
//        }
//    } else if ptyCode == .rainSnow {
//        returnName = "snowySunny"
//        if solar!.isNighttime {
//            returnName = "snowyNight"
//        }
//    } else if ptyCode == .snow {
//        returnName = "snowySunny"
//        if solar!.isNighttime {
//            returnName = "snowyNight"
//        }
//    } else if ptyCode == .rainThunder {
//        returnName = "rainySunnyThunder"
//        if solar!.isNighttime {
//            returnName = "rainyThunder"
//        }
//    }
//    return returnName
//}

//func getWeatherStatusIcon(ptyCode: PTYCodeType, skyCode: SKYCodeType, date: String) -> UIImage? {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyyMMddHHmm"
//    dateFormatter.locale = Locale(identifier: "ko")
//
//    if globalLocationIndex == 0 {
//       // 현재 위치
//       return getCurrentWeatherIcon(ptyCode: ptyCode,
//                                    skyCode: skyCode,
//                                    latitude: AppInfoManager.shared.currentLocation.latitude,
//                                    longitude: AppInfoManager.shared.currentLocation.longitude,
//                                    date: dateFormatter.date(from: date)!,
//                                    mainView: true)
//    } else {
//       // 위치 지정 설정
//       let locationData = try! Realm().objects(RLMLocationSettingInfo.self).filter("idx = %d", globalLocationIndex)
//       if locationData.count > 0 {
//           return getCurrentWeatherIcon(ptyCode: ptyCode,
//                                        skyCode: skyCode,
//                                        latitude: locationData[0].wgs84Lat,
//                                        longitude: locationData[0].wgs84Lon,
//                                        date: dateFormatter.date(from: date)!,
//                                        mainView: true)
//       }
//    }
//    return nil
//}
//
//func getWeatherStatusAnimationIcon(imageView: UIImageView, ptyCode: PTYCodeType, skyCode: SKYCodeType, date: String, latitude: Double = 0.0, longitude: Double = 0.0) {
//    var weatherIconName = "sunAlt"
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyyMMddHHmm"
//    if globalLocationIndex == 0 {
//        // 현재 위치
//        weatherIconName = getCurrentWeatherIconName(ptyCode: ptyCode,
//                                                           skyCode: skyCode,
//                                                           latitude: (latitude == 0.0 ? AppInfoManager.shared.currentLocation.latitude : latitude),
//                                                           longitude: (longitude == 0.0 ? AppInfoManager.shared.currentLocation.longitude : longitude),
//                                                           date: dateFormatter.date(from: date) ?? Date())
//    } else {
//        // 위치 지정 설정
//        let locationData = try! Realm().objects(RLMLocationSettingInfo.self).filter("idx = %d", globalLocationIndex)
//        if locationData.count > 0 {
//            weatherIconName = getCurrentWeatherIconName(ptyCode: ptyCode,
//                                                        skyCode: skyCode,
//                                                       latitude: (latitude == 0.0 ? locationData[0].wgs84Lat : latitude),
//                                                       longitude: (longitude == 0.0 ? locationData[0].wgs84Lon : longitude),
//                                                       date: dateFormatter.date(from: date) ?? Date())
//        }
//    }
//
//    if imageView.subviews.count > 0 {
//        for v in imageView.subviews {
//            v.removeFromSuperview()
//        }
//    }
//
//    let weatherView = AnimationView(name: weatherIconName)
//    imageView.addSubview(weatherView)
//    weatherView.translatesAutoresizingMaskIntoConstraints = false
//    weatherView.loopMode = .loop
//    weatherView.play()
//    weatherView.anchor(top: imageView.topAnchor, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//    weatherView.backgroundColor = .clear
//}

// 체감 온도 공식
func getNewWCT(Tdum: Double, Wdum: Double) -> Double {
    let T = Tdum
    var W = Wdum // W = k/h
    var result = 0.0
    if W > 4.8 {
        W = pow(W, 0.16)
        result = 13.12 + 0.6215 * T - 11.37 * W + 0.3965 * W * T
        if result > T  {
            result = T
        }
    } else {
        result = T
    }
    
    return result
}

/*
 CONVERT MG/M3 TO PPM
 NOTE: To convert units based on 25°C and 1 atm, fill in the ppm value (or the mg/m3 value)

 Formula: concentration (ppm) = 24.45 x concentration (mg/m3) ÷ molecular weight

 For example: 50 mg/m3 of NH3 (17.03 g/mol)
 24.45 x 50 mg/m3 / 17.03 = 71.785ppm
 */
func ugm3ToPPM(value: Double, dustType: DustInfoType) -> Double {
    if dustType == .o3 {
        // Molecular Weight : 48
        return (((value * 0.001) * 24.45) / 48)
    } else if dustType == .so2 {
        // Molecular Weight : 64.07
        return (((value * 0.001) * 24.45) / 64.07)
    } else if dustType == .co {
        // Molecular Weight : 28.01
        return (((value * 0.001) * 24.45) / 28.01)
    } else if dustType == .no2 {
        // Molecular Weight : 46.01
        return (((value * 0.001) * 24.45) / 46.01)
    }
    return 0
}

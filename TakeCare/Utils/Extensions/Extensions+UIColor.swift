//
//  Extensions+UIColor.swift
//  TakeCare
//
//  Created by Min on 2021/11/09.
//

import UIKit

fileprivate func setColorMode(darkMode: UIColor, lightMode: UIColor) -> UIColor {
    if #available(iOS 13, *) {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                // Return color for Dark Mode
                return darkMode
            } else {
                // Return color for Light Mode
                return lightMode
            }
        }
    } else {
        // Return fallback color for iOS 12 and lower
        return lightMode
    }
}
// = setColorMode(darkMode: <#T##UIColor#>, lightMode: <#T##UIColor#>)
extension UIColor {
    static let r0g0b0a04       = setColorMode(darkMode: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.4), lightMode: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.4))
    static let r25g42b138a1    = setColorMode(darkMode: UIColor(red: 25/255.0, green: 42/255.0, blue: 138/255.0, alpha: 1), lightMode: UIColor(red: 25/255.0, green: 42/255.0, blue: 138/255.0, alpha: 1))
    static let r51g51b51a1     = setColorMode(darkMode: UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1), lightMode: UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1))
    static let r66g85b194a1    = setColorMode(darkMode: UIColor(red: 66/255.0, green: 85/255.0, blue: 194/255.0, alpha: 1), lightMode: UIColor(red: 66/255.0, green: 85/255.0, blue: 194/255.0, alpha: 1))
    static let r102g102b102a1  = setColorMode(darkMode: UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1), lightMode: UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1))
    static let r153g153b153a1  = setColorMode(darkMode: UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1), lightMode: UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1))
    static let r170g170b170a1  = setColorMode(darkMode: UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1), lightMode: UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1))
    static let r187g187b187a1  = setColorMode(darkMode: UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1), lightMode: UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1))
    static let r196g196b196a1  = setColorMode(darkMode: UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 1), lightMode: UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 1))
    static let r204g204b204a1  = setColorMode(darkMode: UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1), lightMode: UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1))
    static let r221g221b221a1  = setColorMode(darkMode: UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1), lightMode: UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1))
    static let r233g233b233a1  = setColorMode(darkMode: UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1), lightMode: UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1))
    static let r234g234b234a1  = setColorMode(darkMode: UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1), lightMode: UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1))
    static let r236g238b251a1  = setColorMode(darkMode: UIColor(red: 236/255.0, green: 238/255.0, blue: 251/255.0, alpha: 1), lightMode: UIColor(red: 236/255.0, green: 238/255.0, blue: 251/255.0, alpha: 1))
    static let r238g238b238a1  = setColorMode(darkMode: UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1), lightMode: UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1))
    static let r242g244b252a1  = setColorMode(darkMode: UIColor(red: 242/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1), lightMode: UIColor(red: 242/255.0, green: 244/255.0, blue: 252/255.0, alpha: 1))
    static let r246g246b246a1  = setColorMode(darkMode: UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1), lightMode: UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1))
    static let r255g201b62a1   = setColorMode(darkMode: UIColor(red: 255/255.0, green: 201/255.0, blue: 62/255.0, alpha: 1), lightMode: UIColor(red: 255/255.0, green: 201/255.0, blue: 62/255.0, alpha: 1))
    static let white           = setColorMode(darkMode: UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), lightMode: UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1))
    static let clear           = setColorMode(darkMode: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.0), lightMode: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.0))
    static let black           = setColorMode(darkMode: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1), lightMode: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1))
    static let warning         = setColorMode(darkMode: UIColor(red: 1.0, green: 100.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0), lightMode: UIColor(red: 1.0, green: 100.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0))
    static let secondaryYellow = setColorMode(darkMode: UIColor(red: 1.0, green: 201.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0), lightMode: UIColor(red: 1.0, green: 201.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0))
    static let primaryBlue02   = setColorMode(darkMode: UIColor(red: 25.0 / 255.0, green: 42.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0), lightMode: UIColor(red: 25.0 / 255.0, green: 42.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0))
    static let success         = setColorMode(darkMode: UIColor(red: 0.0, green: 170.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0), lightMode: UIColor(red: 0.0, green: 170.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0))
    static let primaryBlue01   = setColorMode(darkMode: UIColor(red: 66.0 / 255.0, green: 85.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0), lightMode: UIColor(red: 66.0 / 255.0, green: 85.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0))
    static let danger          = setColorMode(darkMode: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), lightMode: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
}

extension UIColor {
    func brightened(by factor: CGFloat) -> UIColor {
        var hueV: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hueV, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hueV, saturation: saturation, brightness: brightness * factor, alpha: alpha)
    }

    // notaTODO: - Computed Properties
    var toHex: String? {
        return toHex()
    }

    // notaTODO: - From UIColor to String
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let red = Float(components[0])
        let green = Float(components[1])
        let black = Float(components[2])
        var alpha = Float(1.0)

        if components.count >= 4 {
            alpha = Float(components[3])
        }

        if alpha > 0 {
            return String(format: "%02lX%02lX%02lX%02lX",
                          lroundf(red * 255), lroundf(green * 255), lroundf(black * 255), lroundf(alpha * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(black * 255))
        }
    }
}

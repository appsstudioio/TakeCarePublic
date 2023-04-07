//
//  Extensions+UIFont.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

extension UIFont {
    enum FontStyle: Int {
        case thin       = 100
        case extraLight = 200
        case light      = 300
        case regular    = 400
        case medium     = 500
        case semiBold   = 600
        case bold       = 700
        case extraBold  = 800
        case black      = 900
    }

    convenience init(fontsStyle: FontStyle, size: CGFloat) {
        var fontName = ""
        switch fontsStyle {
        case .thin:
            fontName = "Binggrae"
        case .extraLight:
            fontName = "Binggrae"
        case .light:
            fontName = "Binggrae"
        case .regular:
            fontName = "Binggrae"
        case .medium:
            fontName = "Binggrae"
        case .semiBold:
            fontName = "Binggrae-Bold"
        case .bold:
            fontName = "Binggrae-Bold"
        case .extraBold:
            fontName = "Binggrae-Bold"
        case .black:
            fontName = "Binggrae-Bold"
        }
        self.init(name: fontName, size: size)!
    }

    private func getFontName(style: UIFont.Weight) -> String {
        switch style {
        case .thin:
            return "AppleSDGothicNeo-Thin"
        case .ultraLight:
            return "AppleSDGothicNeo-UltraLight"
        case .light:
            return "AppleSDGothicNeo-Light"
        case .regular:
            return "AppleSDGothicNeo-Regular"
        case .medium:
            return "AppleSDGothicNeo-Medium"
        case .semibold:
            return "AppleSDGothicNeo-SemiBold"
        case .bold:
            return "AppleSDGothicNeo-Bold"
        case .heavy:
            return "AppleSDGothicNeo-Bold"
        case .black:
            return "AppleSDGothicNeo-Bold"
        default:
            return "AppleSDGothicNeo-Regular"
        }
    }

    static func getMainFont(style: UIFont.Weight, size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: style)
    }
}

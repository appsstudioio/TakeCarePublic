//
//  Extensions+UIAppliciton.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/04/15.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

extension UIApplication {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            guard self.shared.windows.count > 0 else { return nil }
            return self.shared.windows.first { $0.isKeyWindow }
        } else {
            return self.shared.keyWindow
        }
    }

   static var viewSafeAreaInsets: UIEdgeInsets {
        var defaultEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if #available(iOS 13, *) {
            if self.shared.windows.count > 0 {
                if let edge = self.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets {
                    defaultEdgeInsets = edge
                }
            }
        } else {
            defaultEdgeInsets = self.shared.keyWindow?.safeAreaInsets ?? defaultEdgeInsets
        }
        return defaultEdgeInsets
    }

    class func topViewController(base: UIViewController? = UIApplication.key?.rootViewController) -> UIViewController? {
        if base is UITabBarController {
            let control = base as? UITabBarController
            return topViewController(base: control?.selectedViewController)
        } else if base is UINavigationController {
            let control = base as? UINavigationController
            return topViewController(base: control?.visibleViewController)
        } else if let control = base?.presentedViewController {
            return topViewController(base: control)
        }
        return base
    }

    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.open(URL(string: url)!, options: [:], completionHandler: nil)
                return
            }
        }
    }
}

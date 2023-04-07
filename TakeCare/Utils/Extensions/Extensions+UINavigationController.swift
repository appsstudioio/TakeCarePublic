//
//  Extensions+UINavigationController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/04/15.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

extension UINavigationController {
    // https://stackoverflow.com/questions/8236940/how-do-i-pop-two-views-at-once-from-a-navigation-controller
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let lastVC = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(lastVC, animated: animated)
        }
    }

    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let popVC = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(popVC, animated: animated)
        }
    }
}

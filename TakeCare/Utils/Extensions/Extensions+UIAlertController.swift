//
//  Extensions+UIAlertController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/12/21.
//  Copyright © 2021 Apps Studio. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    static public func showAlert(_ title: String,
                                 _ message: String,
                                 _ controller: UIViewController,
                                 _ handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: handler))
        controller.present(alert, animated: true, completion: nil)
    }
}

//
//  Extensions+UIViewController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/04/15.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

extension UIViewController {
    // notaTODO: Show Alert For Error Code
    func alertWith(title: String = "", message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }

    func alertWith(title: String = "", message: String, completionHandler: @escaping (Bool) -> Void) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
            completionHandler(true)
        }))
        present(alertView, animated: true, completion: nil)
    }

    func alertWith(title: String = "", message: String, actionButtons: [UIAlertAction]) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for actionBtn in actionButtons {
            alertView.addAction(actionBtn)
        }
        DispatchQueue.main.async {
            self.present(alertView, animated: true, completion: nil)
        }
    }

    func showActivityViewController(activityItems: [Any], sourceRect: CGRect, animated: Bool = false, completion: (() -> Void)? = nil) {
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        if #available(iOS 13.2, *) {
            activityVC.popoverPresentationController?.sourceRect = sourceRect
        }
        self.present(activityVC, animated: animated, completion: completion)
    }
}

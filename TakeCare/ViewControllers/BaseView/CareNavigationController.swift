//
//  CareNavigationController.swift
//  TakeCare
//
//  Created by Lim on 09/09/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import XLPagerTabStrip
class CareNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let vc = topViewController as? ButtonBarPagerTabStripViewController  {
            // 뷰를 뒤로 이동할때 스크롤을 멈추게하여 부자연스러움을 막음
            if viewControllers.count > 1 {
                vc.containerView.isScrollEnabled = false
            }
        }
        
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}

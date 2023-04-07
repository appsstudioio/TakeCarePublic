//
//  ScheduleDetailMainViewController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2020/02/07.
//  Copyright © 2020 Apps Studio. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RealmSwift

class ScheduleDetailMainViewController: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var naviView: UIView!
    
    var childPagerViewControllers: [UIViewController] = []
    var childInfoList: Results<RLMChildInfo>? = nil
    let realm: Realm = try! Realm()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBeingPresented || isMovingToParent {
            // 화면 전환이 일을때 한번
            self.containerView.isScrollEnabled = true
        }
    }
    
    override func viewDidLoad() {
        setCustomTabBar()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        backButton.setImage(globalBackBtImage, for: .normal)
        backButton.tintColor       = AppColorList().naviTitleColor
        backButton.imageEdgeInsets = globalBackBtEdgeInsets
        titleLabel.font = UIFont(fontsStyle: .regular, size: 18.0)
        let lineView = UIView()
        lineView.backgroundColor = AppColorList().lineColor
        lineView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(lineView)
        
        buttonBarView.anchor(top: naviView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        lineView.anchor(top: buttonBarView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        containerView.anchor(top: buttonBarView.bottomAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        buttonBarView.selectedBar.backgroundColor = AppColorList().naviTitleColor
        buttonBarView.backgroundColor = AppColorList().naviBgColor
        
        AnalyticsManager.shared.screenName(screenName:"일정 상세정보 화면", screenClass: "ScheduleDetailView")
    }
    
    @IBAction func backView(_ sender: Any) {
       self.navigationController?.popViewController(animated: true)
    }
   
    override var prefersStatusBarHidden: Bool {
       return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
       return .default
    }

    override var hidesBottomBarWhenPushed: Bool {
       get { return true }
       set { super.hidesBottomBarWhenPushed = newValue }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       // Trait collection has already changed
       if #available(iOS 12.0, *) {
           let userInterfaceStyle = self.traitCollection.userInterfaceStyle
           if userInterfaceStyle == .dark {
              DLog("===== Dark Mode")
           } else {
              DLog("===== \(userInterfaceStyle.rawValue) Mode")
           }
//           tableView.reloadData()
       }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        childPagerViewControllers.removeAll()
        do {
            childInfoList = try Realm().objects(RLMChildInfo.self).sorted(byKeyPath: "mainFlag", ascending: false)
            if childInfoList?.count ?? 0 > 0 {
                for info in childInfoList! {
                    let child = ScheduleDetailChildViewController(data: info)
                    childPagerViewControllers.append(child)
                }
            }
        } catch let error as NSError {
           // handle error
           DLog("error : \(error)")
           childInfoList = nil
        }
        
        return childPagerViewControllers
    }
    
    private func setCustomTabBar() {
        settings.style.buttonBarBackgroundColor = AppColorList().naviBgColor
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemFont = UIFont(fontsStyle: .regular, size: 14)
        settings.style.selectedBarHeight = 1
        settings.style.selectedBarBackgroundColor = AppColorList().naviBgColor
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
           guard changeCurrentIndex == true else { return }
           oldCell?.label.textColor = AppColorList().textColorLightGray
           newCell?.label.textColor = AppColorList().naviTitleColor
        }
    }
}

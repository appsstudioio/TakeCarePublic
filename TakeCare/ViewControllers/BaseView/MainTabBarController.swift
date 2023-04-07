//
//  MainTabBarController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 23/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    var preVC: UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
        setTabBarImg()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func setTabBarImg() {
        let tabbarItems = self.tabBar.items
        // UIImage(named: "tabbarIcon-clinic")!, UIImage(named: "tabbarIcon-clinic-filled")!,
        let itemUnselected : [UIImage] = [UIImage(named: "tabbarIcon-mother")!, UIImage(named: "tabbarIcon-more")!]
        let itemSelected : [UIImage] = [UIImage(named: "tabbarIcon-mother-filled")!, UIImage(named: "tabbarIcon-more-filled")!]

        for (i, item) in (tabbarItems?.enumerated())! {
            if i == 0 {
                
            }
            item.image = itemUnselected[i].withRenderingMode(.alwaysTemplate)
            item.selectedImage = itemSelected[i].withRenderingMode(.alwaysTemplate)
            // item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        self.tabBar.tintColor = AppColorList().tabBarSelectColor
        self.tabBar.unselectedItemTintColor = AppColorList().tabBarNormalColor
        self.tabBar.barTintColor = AppColorList().tabBarBgColor
        self.tabBar.isTranslucent = false
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let naviVc = viewController as? UINavigationController, let vc = naviVc.viewControllers.last {
            if vc == preVC || preVC == nil {
                for view in vc.view.subviews {
                    if view.isKind(of: UITableView.self) {
                        let tableView = view as? UITableView
                        tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        break
                    } else if view.isKind(of: UIScrollView.self) {
                        let scrollView = view as? UIScrollView
                        scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                        break
                    } else if view.isKind(of: UICollectionView.self) {
                        let collectionView = view as? UICollectionView
                        collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        break
                    }
                }
            }
            preVC = vc
        }
    }
}

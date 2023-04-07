//
//  ChildSettingViewController.swift
//  TakeCare
//
//  Created by Lim on 2019/11/15.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import RealmSwift

class ChildSettingViewController: UIViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var childInfoList: Results<RLMChildInfo>? = nil
    let realm: Realm = try! Realm()
    var preIndex:Int = 0
    weak var parentVC: UIViewController?
    
    func reloadData() {
        do {
           childInfoList = try Realm().objects(RLMChildInfo.self).sorted(byKeyPath: "idx", ascending: true)
        } catch let error as NSError {
           // handle error
           DLog("error : \(error)")
           childInfoList = nil
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        backButton.setImage(globalBackBtImage, for: .normal)
        backButton.tintColor       = AppColorList().naviTitleColor
        backButton.imageEdgeInsets = globalBackBtEdgeInsets
        
        addButton.setImage(UIImage.init(icon: .googleMaterialDesign(.personAdd), size: CGSize(width: 25, height: 25), textColor:AppColorList().naviTitleColor, backgroundColor: .clear), for: .normal)
        tableView.register(UINib(nibName: babyInfoTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: babyInfoTableViewCellIdentifier)
        preIndex = globalLocationIndex
        AnalyticsManager.shared.screenName(screenName: "아이 정보 화면", screenClass: "ChildSettingView")
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
    
    @IBAction func addBtn(_ sender: Any) {
        let addView = self.storyboard?.instantiateViewController(withIdentifier: "ChildEditingViewControllerSID") as! ChildEditingViewController
        addView.editMode = .write
        addView.parentVC = self
        addView.modalPresentationStyle = .overFullScreen
        addView.providesPresentationContextTransitionStyle = true
        addView.definesPresentationContext = true
        self.present(addView, animated: true, completion: nil)
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
            
            addButton.setImage(UIImage.init(icon: .fontAwesomeSolid(.plus), size: CGSize(width: 20, height: 20), textColor:AppColorList().naviTitleColor, backgroundColor: .clear), for: .normal)
            tableView.reloadData()
        }
    }
    
    @IBAction func backView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChildSettingViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: babyInfoTableViewCellIdentifier) as? BabyInfoTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        if childInfoList?.count ?? 0 > 0 {
            cell.bottomLine.isHidden = false
            cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 0)
            if (childInfoList!.count - 1) == indexPath.row {
                cell.bottomLine.isHidden = true
                cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
            }
            cell.setData(cellType: .settingType, data: (childInfoList?[indexPath.row])!)
        } else {
            cell.bottomLine.isHidden = true
            cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
            cell.setData(cellType: .settingType, data: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let modifyView = self.storyboard?.instantiateViewController(withIdentifier: "ChildEditingViewControllerSID") as! ChildEditingViewController
        if childInfoList?.count ?? 0 > 0 {
            modifyView.editMode = .modify
            modifyView.childInfo = childInfoList?[indexPath.row]
        } else {
            modifyView.editMode = .write
            modifyView.childInfo = nil
        }
        modifyView.parentVC = self
        modifyView.modalPresentationStyle = .overFullScreen
        modifyView.providesPresentationContextTransitionStyle = true
        modifyView.definesPresentationContext = true
        self.present(modifyView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return babyInfoTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (childInfoList!.count == 0 ? 1 : childInfoList!.count)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if childInfoList!.count == 0 {
            return false
        }
        return true
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let select = UIContextualAction(style: .normal, title: ((childInfoList?[indexPath.row].mainFlag)! ? "\u{2605}\n대표아이" : "\u{2606}\n대표아이")) { (action, sourceView, completionHandler) in
            DLog("index path of delete: \(indexPath)")
            if self.childInfoList?.count ?? 0 > 0 {
                 try! self.realm.write {
                    for i in 0 ..< self.childInfoList!.count {
                        self.childInfoList?[i].mainFlag = false
                    }
                 }
                 
                 try! self.realm.write {
                     self.childInfoList?[indexPath.row].mainFlag = true
                 }
            }
            tableView.reloadData()
            completionHandler(true)
        }
        select.backgroundColor = AppColorList().weatherTempMinColor
        
        let swipeAction = UISwipeActionsConfiguration(actions: [select])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
        return swipeAction

    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "\u{2717}\n삭제") { (action, sourceView, completionHandler) in
            DLog("index path of delete: \(indexPath)")
            if self.childInfoList?.count ?? 0 > 0 {
                if self.childInfoList?[(indexPath.row)].mainFlag == false {
                    try! self.realm.write {
                        self.realm.delete((self.childInfoList?[(indexPath.row)])!)
                    }
                    tableView.deleteRows(at: [indexPath], with: .left)
                } else {
                    DLog("아이삭제 불가")
                    toastView(view: tableView, message: "대표아이는 삭제가 불가능 합니다.", duration: 3.0, position: .bottom, title: nil)
                }
            }
            completionHandler(true)
        }
        delete.backgroundColor = AppColorList().weatherTempMaxColor
        
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
        return swipeAction
    }
}

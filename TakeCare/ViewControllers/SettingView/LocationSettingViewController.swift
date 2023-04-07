//
//  LocationSettingViewController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 30/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import RealmSwift

class LocationSettingViewController: UIViewController {
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var locationInfoList: Results<RLMLocationSettingInfo>? = nil
    let realm: Realm = try! Realm()
    var preIndex:Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            locationInfoList = try Realm().objects(RLMLocationSettingInfo.self).sorted(byKeyPath: "regDate", ascending: true)
        } catch let error as NSError {
            // handle error
            DLog("error : \(error)")
            locationInfoList = nil
        }

        locationTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        settingButton.setIcon(icon: .googleMaterialDesign(.check), iconSize: 25, color: AppColorList().naviTitleColor, forState: .normal)
        addButton.setImage(UIImage.init(icon: .googleMaterialDesign(.add), size: CGSize(width: 25, height: 25), textColor:AppColorList().naviTitleColor, backgroundColor: .clear), for: .normal)
        locationTableView.register(UINib(nibName: locationSettingTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: locationSettingTableViewCellIdentifier)
        preIndex = globalLocationIndex
        AnalyticsManager.shared.screenName(screenName: "위치 설정 화면", screenClass: "LocationSettingView")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func addBtn(_ sender: Any) {
        let addView = self.storyboard?.instantiateViewController(withIdentifier: "LocationAddViewControllerSID") as! LocationAddViewController
        self.navigationController?.pushViewController(addView, animated: true)
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
            locationTableView.reloadData()
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        globalLocationIndex = getAppSettingLocationIndex()
        // 위치설정을 변경했다면...
        if self.preIndex != globalLocationIndex {
            // 변경했다면.. 데이터 호출..
            AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "LcationSetting", itemName: "위치설정", contentType: "Modify")
            globalLocationChangeReloadTab1 = true
            globalLocationChangeReloadTab2 = true
        }
        self.dismiss(animated: true)
    }
}

extension LocationSettingViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: locationSettingTableViewCellIdentifier) as? LocationSettingTableViewCell else { return UITableViewCell() }
        cell.lineView.isHidden = false
        if indexPath.row == 0 {
            cell.locationImageView.image = UIImage.init(icon: .fontAwesomeSolid(.locationArrow), size: cell.locationImageView.frame.size, textColor: AppColorList().redColor, backgroundColor: .clear)
            cell.locationNameLabel.text = "현재위치"
            cell.locationSettingButton.isSelected = (getAppSettingLocationIndex() == 0 ? true : false)
            if locationInfoList!.count == 0 {
               cell.lineView.isHidden = true
            }
        } else {
            if locationInfoList!.count > 0 {
                guard let data = locationInfoList?[(indexPath.row - 1)] else { return cell }
                cell.locationImageView.image = UIImage.init(icon: .fontAwesomeSolid(.mapMarkerAlt), size: cell.locationImageView.frame.size, textColor: AppColorList().redColor, backgroundColor: .clear)
                cell.locationNameLabel.text = locationInfoList?[(indexPath.row - 1)].addressName
                cell.locationSettingButton.isSelected = data.selectedFlag
                if locationInfoList!.count == indexPath.row {
                    cell.lineView.isHidden = true
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if locationInfoList!.count > 0 {
            try! realm.write {
                for i in 0 ..< locationInfoList!.count {
                    locationInfoList?[i].selectedFlag = false
                }
            }
        }
        
        if indexPath.row == 0 {
            saveAppSettingLocationIndex(indexValue: 0)
        } else {
            saveAppSettingLocationIndex(indexValue: locationInfoList![(indexPath.row - 1)].idx)
            try! realm.write {
                locationInfoList![(indexPath.row - 1)].selectedFlag = true
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return locationSettingTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (locationInfoList!.count == 0 ? 1 : locationInfoList!.count + 1)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "\u{2717}\n삭제") { (action, sourceView, completionHandler) in
            if self.locationInfoList?[(indexPath.row - 1)].selectedFlag == false {
                DLog("index path of delete: \(indexPath)")
                try! self.realm.write {
                    self.realm.delete((self.locationInfoList?[(indexPath.row - 1)])!)
                }
                tableView.deleteRows(at: [indexPath], with: .left)
            } else {
                DLog("위치삭제 불가")
                toastView(view: tableView, message: "선택한 위치는 삭제가 불가능 합니다.", duration: 2.0, position: .bottom, title: nil)
            }
            completionHandler(true)
        }
        
        delete.backgroundColor = AppColorList().weatherTempMaxColor
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
        return swipeAction
    }
}

//
//  moreViewController.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class MoreViewController: UIViewController {
    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let menuList: [MoreSubMenuName] = [.devBlog, .qnaMail, .policy, .openSource, .versionInfo]
    // .distanceSetting, .perPageSetting, .openHospSetting, 
    let menuSettingList: [MoreSubMenuName] = [.alarmSetting]
    var settingChangeFlag: Bool = false
    let bannerADView = AdFitBannerAdView(clientId: "clientId", adUnitSize: "300x100")
//    let sectionArray: [MoreMenuName] = [.appSetting, .appInfo]
    let sectionArray: [MoreMenuName] = [.babyProfile, .appSetting, .appInfo]
    var childInfoList: Results<RLMChildInfo>? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        do {
            childInfoList = try Realm().objects(RLMChildInfo.self).filter("mainFlag == true")
        } catch let error as NSError {
            // handle error
            DLog("error : \(error)")
            childInfoList = nil
        }
        moreTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        moreTableView.register(UINib(nibName: moreViewTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: moreViewTableViewCellIdentifier)
        moreTableView.register(UINib(nibName: babyInfoTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: babyInfoTableViewCellIdentifier)
        
        titleLabel.font = UIFont(fontsStyle: .regular, size: 18.0)
        bannerADView.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        bannerADView.delegate = self
        bannerADView.isUserInteractionEnabled = true
        bannerRequest()
        
        AnalyticsManager.shared.screenName(screenName: "더보기(설정)화면", screenClass: "MoreView")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if settingChangeFlag == true {
            /* 앱 설정값 불러오기 */
            globalDistance     = getAppSettingDistance()
            globalOpenHospFlag = getAppSettingHospOpenFlag()
            // 데이터 호출..
            globalLocationChangeReloadTab2 = true
            // 탭바에서는 뷰컨트롤러가 초기화 되지 않는다.. 해당 값을 false로 변경해 주어여 함.
            settingChangeFlag = false
        }
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
            moreTableView.reloadData()
        }
    }
}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionArray[section] == .appInfo {
            return menuList.count
        } else if sectionArray[section] == .appSetting {
            return menuSettingList.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sectionArray[indexPath.section] == .babyProfile {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: babyInfoTableViewCellIdentifier) as? BabyInfoTableViewCell else { return UITableViewCell() }
            cell.bottomLine.isHidden = true
            cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
            if childInfoList?.count ?? 0 > 0 {
                cell.setData(cellType: .infoType, data: (childInfoList?[indexPath.row])!)
            } else {
                cell.setData(cellType: .infoType, data: nil)
            }
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: moreViewTableViewCellIdentifier) as? MoreViewTableViewCell else { return UITableViewCell() }
            
            let menuName = sectionArray[indexPath.section] == .appInfo ? menuList[indexPath.row] : menuSettingList[indexPath.row]

            cell.menuBottomLine.isHidden = false
            cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 0)
            if sectionArray[indexPath.section] == .appInfo && (menuList.count - 1) == indexPath.row {
                cell.menuBottomLine.isHidden = true
                cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
            } else if sectionArray[indexPath.section] == .appSetting && (menuSettingList.count - 1) == indexPath.row {
                cell.menuBottomLine.isHidden = true
                cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
            }

            cell.menuArrowImageView.image = UIImage.init(icon: .googleMaterialDesign(.keyboardArrowRight), size: CGSize(width: (cell.menuArrowImageView.frame.size.width), height: (cell.menuArrowImageView.frame.size.height)), textColor:AppColorList().textColorLightGray, backgroundColor: .clear)
            cell.menuSubTitleLabel.textColor = AppColorList().textColorLightGray
            switch menuName {
                case .devBlog:
                    cell.menuTitleLabel.text = NSLocalizedString("devBlog", comment: "")
                    cell.menuSubTitleLabel.isHidden = true
                    cell.menuArrowImageView.isHidden = false
                    cell.selectionStyle = .none
                break
                case .qnaMail:
                    cell.menuTitleLabel.text = NSLocalizedString("qnaMail", comment: "")
                    cell.menuSubTitleLabel.isHidden = true
                    cell.menuArrowImageView.isHidden = false
                    cell.selectionStyle = .none
                break
                case .openSource:
                    cell.menuTitleLabel.text = NSLocalizedString("openSource", comment: "")
                    cell.menuSubTitleLabel.isHidden = true
                    cell.menuArrowImageView.isHidden = false
                    cell.selectionStyle = .none
                break
                case .versionInfo:
                    cell.menuTitleLabel.text = NSLocalizedString("versionInfo", comment: "")
                    cell.menuSubTitleLabel.isHidden = false
                    if let data = RemoteConfigManager.shared.appConfigList,
                       data.verInfo!.currentVersion > AppInfoManager.shared.appCurrentVersion {
                        cell.menuSubTitleLabel.text = "신규버전출시!"
                        cell.menuSubTitleLabel.textColor = AppColorList().redColor
                        cell.selectionStyle = .none
                    } else {
                        cell.menuSubTitleLabel.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
                        cell.selectionStyle = .none
                    }
                    cell.menuArrowImageView.isHidden = false
                break
                case .policy:
                    cell.menuTitleLabel.text = NSLocalizedString("policy", comment: "")
                    cell.menuSubTitleLabel.isHidden = true
                    cell.menuArrowImageView.isHidden = false
                    cell.selectionStyle = .none
                break
                case .distanceSetting:
                    cell.menuTitleLabel.text = NSLocalizedString("distanceSetting", comment: "")
                    cell.menuSubTitleLabel.isHidden = false
                    cell.menuSubTitleLabel.text = "\(getAppSettingDistance())Km"
                    cell.menuArrowImageView.isHidden = false
                    cell.selectionStyle = .none
                break
                case .perPageSetting:
                    cell.menuTitleLabel.text = NSLocalizedString("perPageSetting", comment: "")
                    cell.menuSubTitleLabel.isHidden = false
                    cell.menuSubTitleLabel.text = "\(getAppSettingPerPage())개"
                    cell.menuArrowImageView.isHidden = false
                    cell.selectionStyle = .none
                break
                case .openHospSetting:
                    cell.menuTitleLabel.text = NSLocalizedString("openHospSetting", comment: "")
                    cell.menuSubTitleLabel.isHidden = false
                    cell.menuSubTitleLabel.text = (getAppSettingHospOpenFlag() == true ? "진료중" : "전체" )
                    cell.menuSubTitleLabel.textColor = (getAppSettingHospOpenFlag() == true ? AppColorList().greenColor : AppColorList().textColorLightGray)
                    cell.menuArrowImageView.isHidden = false
                    cell.selectionStyle = .none
                break
                case .alarmSetting:
                    cell.menuTitleLabel.text = NSLocalizedString("alarmSetting", comment: "")
                    cell.menuSubTitleLabel.isHidden = false
                    cell.menuSubTitleLabel.text = (getAppLocalNotification() == "OFF" ? "꺼짐" : getAppLocalNotification() )
                    cell.menuSubTitleLabel.textColor = (getAppLocalNotification() == "OFF" ? AppColorList().redColor : AppColorList().greenColor)
                    cell.menuArrowImageView.isHidden = false
                    cell.selectionStyle = .none
                break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStroyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if sectionArray[indexPath.section] == .babyProfile {
            if let childInfoView = mainStroyboard.instantiateViewController(withIdentifier: "ChildSettingViewControllerSID") as? ChildSettingViewController {
                self.navigationController?.pushViewController(childInfoView, animated: true)
            }
        } else {
            let menuName = sectionArray[indexPath.section] == .appInfo ? menuList[indexPath.row] : menuSettingList[indexPath.row]
            switch menuName {
                case .devBlog:
                    if let moreView = mainStroyboard.instantiateViewController(withIdentifier: "WebViewControllerSID") as? WebViewController {
                        moreView.urlLink = "https://twitter.com/AppsStudioKr"
                        moreView.moreMenuType = .devBlog
                        self.navigationController?.pushViewController(moreView, animated: true)
                    }
                case .qnaMail:
                    #if true
                    if let moreView = mainStroyboard.instantiateViewController(withIdentifier: "WebViewControllerSID") as? WebViewController {
                        moreView.urlLink = "https://forms.gle/m3Lfvw3oTnB6yHAF8"
                        moreView.moreMenuType = .qnaMail
                        self.navigationController?.pushViewController(moreView, animated: true)
                    }
                    #else
                    let title = NSLocalizedString("qnaMailTitle", comment: "")
                    let mailComposerVC = MFMailComposeViewController()
                    mailComposerVC.mailComposeDelegate = self
                    mailComposerVC.setToRecipients(["limdj61@nate.com"])
                    mailComposerVC.setSubject(title)
                    mailComposerVC.setMessageBody("", isHTML: false)
                    if MFMailComposeViewController.canSendMail() {
                        self.present(mailComposerVC, animated: true, completion: nil)
                    } else {
                        DLog("====== Not Send Mail ======")
                    }
                    #endif
                case .openSource:
                    if let openSourceView = mainStroyboard.instantiateViewController(withIdentifier: "OpensourceListViewControllerSID") as? OpensourceListViewController {
                        openSourceView.titleName = NSLocalizedString("openSource", comment: "")
                        self.navigationController?.pushViewController(openSourceView, animated: true)
                    }
                case .versionInfo:
                    if let data = RemoteConfigManager.shared.appConfigList,
                       data.verInfo!.currentVersion > AppInfoManager.shared.appCurrentVersion {
                        if let url = URL(string: data.verInfo!.appStoreUrl) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    } else {
                        let viewController = SKStoreProductViewController()
                        viewController.delegate = self
                        let parameters = [ SKStoreProductParameterITunesItemIdentifier: 1471938305]
                        viewController.loadProduct(withParameters: parameters, completionBlock: nil)
                        self.present(viewController, animated: true, completion: nil)
                    }
                case .policy:
                    if let moreView = mainStroyboard.instantiateViewController(withIdentifier: "WebViewControllerSID") as? WebViewController {
                        moreView.urlLink = "https://appsstudioio.github.io/terms/index.html"
                        moreView.moreMenuType = .policy
                        self.navigationController?.pushViewController(moreView, animated: true)
                    }
                case .distanceSetting:
                    let alert = UIAlertController(title: "검색 반경", message: nil, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "1Km", style: (getAppSettingDistance() == 1 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingDistance(distance: 1)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "3Km", style: (getAppSettingDistance() == 3 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingDistance(distance: 3)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "5Km", style: (getAppSettingDistance() == 5 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingDistance(distance: 5)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "10Km", style: (getAppSettingDistance() == 10 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingDistance(distance: 10)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "15Km", style: (getAppSettingDistance() == 15 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingDistance(distance: 15)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "20Km", style: (getAppSettingDistance() == 20 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingDistance(distance: 20)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler:nil))
                    self.present(alert, animated: true, completion:nil)
                case .perPageSetting:
                    let alert = UIAlertController(title: "목록 갯수", message: nil, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "30개", style: (getAppSettingPerPage() == 30 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingPerPage(perPage: 30)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "40개", style: (getAppSettingPerPage() == 40 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingPerPage(perPage: 40)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "50개", style: (getAppSettingPerPage() == 50 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingPerPage(perPage: 50)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "70개", style: (getAppSettingPerPage() == 70 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingPerPage(perPage: 70)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "100개", style: (getAppSettingPerPage() == 100 ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingPerPage(perPage: 100)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler:nil))
                    self.present(alert, animated: true, completion:nil)
                case .openHospSetting:
                    let alert = UIAlertController(title: "운영 중 병원", message: nil, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "전체", style: (getAppSettingHospOpenFlag() == false ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingHospOpenFlag(flag: false)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "진료가능한 경우만", style: (getAppSettingHospOpenFlag() == true ? .destructive : .default) , handler:{ (UIAlertAction) in
                        saveAppSettingHospOpenFlag(flag: true)
                        self.moreTableView.reloadData()
                        self.settingChangeFlag = true
                    }))
                    alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler:nil))
                    self.present(alert, animated: true, completion:nil)
            case .alarmSetting:
                let alert = UIAlertController(title: "알림 설정", message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "켜기(시간 설정)", style: (getAppSettingHospOpenFlag() == false ? .destructive : .default) , handler:{ (UIAlertAction) in
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.requestLocalNotification()
                    }

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    dateFormatter.locale = Locale(identifier: "ko")
                    let settingTimeVaue: Date = getAppLocalNotification() == "OFF" ? Date() : dateFormatter.date(from: getAppLocalNotification())!
                    let alert = UIAlertController(title: nil, message: "시간 설정", preferredStyle: .actionSheet)
                    alert.addDatePicker(mode: .time, date: settingTimeVaue, minimumDate: nil, maximumDate: Date()) { date in
                        saveAppLocalNotification(value: dateFormatter.string(from: date))
                    }
                    alert.addAction(title: "확인", style: .cancel , handler:{ (UIAlertAction) in
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.settingLocalNotification(type: .dailyReport, title: "일일 알림", message: "오늘의 브리핑이 업데이트 되었어요.^^\n현재 날씨 및 미세먼지 정보를 확인하세요. ", date: dateFormatter.date(from: getAppLocalNotification())!)
                        }
                        self.moreTableView.reloadData()
                    })
                    self.present(alert, animated: true, completion:nil)
                }))
                alert.addAction(UIAlertAction(title: "끄기", style: (getAppSettingHospOpenFlag() == true ? .destructive : .default) , handler:{ (UIAlertAction) in
                    saveAppLocalNotification(value: "OFF")
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        // 알림 전체 삭제..
                        appDelegate.removeLocalNotification(type: nil)
                    }
                    self.moreTableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler:nil))
                self.present(alert, animated: true, completion:nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sectionArray[indexPath.section] == .babyProfile {
            return babyInfoTableViewCellHeight
        }
        return moreViewTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if sectionArray[section] == .appInfo {
            let bannerBoxView = ADBoxFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (65 + 100)), type: .middle(width: 320, height: 100))
            bannerBoxView.bannerFrameView.addSubview(bannerADView)
            return bannerBoxView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if sectionArray[section] == .appInfo {
            return (65 + 100)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 50.0))
        headerView.backgroundColor = .clear

        let label = UILabel(frame: CGRect(x: 10.0, y: 10.0, width: (headerView.frame.size.width - 20), height: 40.0))
        label.font = UIFont(fontsStyle: .regular, size: 14.0)
        label.textColor = AppColorList().textColorDarkText
        label.backgroundColor = AppColorList().tableCellBgColor
        label.roundCorners(corners: [.topLeft, .topRight], radius: 5)
        if sectionArray[section] == .appInfo {
            label.text = "  " + NSLocalizedString("more_section_appinfo_title", comment: "")
        } else if sectionArray[section] == .appSetting {
            label.text = "  " + NSLocalizedString("more_section_appsetting_title", comment: "")
        } else if sectionArray[section] == .babyProfile {
            label.text = "  " + NSLocalizedString("more_section_babyprofile_title", comment: "")
        }
        headerView.addSubview(label)
        
        let lineView = UIView(frame: CGRect(x: 10.0, y: 49, width: label.frame.size.width, height: 1.0))
        lineView.backgroundColor = AppColorList().lineColor
        headerView.addSubview(lineView)
        return headerView
    }

}

extension MoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension MoreViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension MoreViewController: AdFitBannerAdViewDelegate {
    @objc func bannerRequest() {
        bannerADView.loadAd()
    }
    
    func adViewDidReceiveAd(_ bannerAdView: AdFitBannerAdView) {
        DLog("didReceiveAd")
        AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "BannerAd", itemName: "Ad Fit 배너광고 로드", contentType: "AdLoad")
    }
    
    func adViewDidFailToReceiveAd(_ bannerAdView: AdFitBannerAdView, error: Error) {
        DLog("didFailToReceiveAd - error :\(error.localizedDescription)")
        AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "BannerAd", itemName: "Ad Fit 배너광고 오류", contentType: "AdFail")
        // 60초후에 다시 요청
        Timer.scheduledTimer(timeInterval: 60,
                                   target: self,
                                 selector: #selector(bannerRequest),
                                 userInfo: nil,
                                  repeats: false)
    }
    
    func adViewDidClickAd(_ bannerAdView: AdFitBannerAdView) {
        DLog("didClickAd")
        AnalyticsManager.shared.eventLoging(logType: .select_content, itemID: "BannerAd", itemName: "Ad Fit 배너광고 클릭", contentType: "AdClick")
    }
}

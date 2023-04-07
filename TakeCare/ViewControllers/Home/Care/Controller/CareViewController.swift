//
//  CareViewController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/12/15.
//  Copyright © 2021 Apps Studio. All rights reserved.
//

import UIKit
import EasyTipView
import SpringIndicator
import AdFitSDK
import CoreLocation

final class CareViewController: UIViewController {
    // MARK: - views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var naviHeightConstraint: NSLayoutConstraint!
    var locationTipView: EasyTipView? = nil
    let refreshControl = RefreshIndicator()
    let bannerADView = AdFitBannerAdView(clientId: "clientId", adUnitSize: "320x50")

    // MARK: - variables
    var viewModel = CareViewModel()
    //
    var sectionArray: [CareMenuName] = [.briefing, .schedule, .dayWeather, .timeWeather, .dustInfo]

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewModel()
        setView()

        if globalLocationIndex == 0 {
            // 현재 위치
            AppInfoManager.shared.getLocationAddress(location: AppInfoManager.shared.currentLocation) { (adress) in
                self.titleLabel.text = adress
            }
            globalLon = String(AppInfoManager.shared.currentLocation.longitude)
            globalLat = String(AppInfoManager.shared.currentLocation.latitude)
        }

        self.onRefresh()
        AnalyticsManager.shared.screenName(screenName: "돌봄-메인화면", screenClass: "careView")

        // 알림 설정 - 최초 등록..
        if getAppLocalNotification() == "" {
            // 알림 끈다..
            saveAppLocalNotification(value: "OFF")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if globalLocationIndex == 0 {
            if locationTipView == nil && getTipViewOpenFlag(keyName: .hospViewTipFlag) == false {
                locationTipView = EasyTipView(text: "위치를 설정할 수 있어요.\n현재 위치가 아닌 다른 위치를 설정해 보세요.",
                                              preferences: EasyTipView.globalPreferences,
                                              delegate: self)
                locationTipView?.show(animated: true, forView:  self.titleLabel, withinSuperview: self.view)
            }
        }

        // 앱 시작시 공유 데이터 처리
        if shareJsonData != nil {
            shareJsonData = nil
            shareType = ""
            toastView(view: self.view, message: "공유기능은 지원하지 않습니다.", duration: 3.0, position: .bottom, title: nil)
        }

        if globalLocationChangeReloadTab1 == true {
            globalLocationChangeReloadTab1 = false
            tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            Timer.scheduledTimer(timeInterval: 0.5,
                                      target: self,
                                    selector: #selector(onRefreshData),
                                    userInfo: nil,
                                     repeats: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNaviTitleName()
        viewModel.updateScheduleData()

        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding  = 0
            tableView.fillerRowHeight = 0
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
            locationImageView.image = UIImage.init(icon: .fontAwesomeSolid(.checkCircle),
                                                   size: locationImageView.frame.size,
                                                   textColor: AppColorList().textColorLightGray,
                                                   backgroundColor: .clear)
            tableView.reloadData()
        }
    }

    // MARK: - functions
    private func setViewModel() {
        viewModel.onWeatherUpdate = { status in
            stopAnimationIndicator()
            switch status {
            case .success:
                break
            case .fail:
                toastView(view: self.view, message: NSLocalizedString("check_network", comment: ""))
            case .timeout:
                if let reloadDate = getWeatherReloadDate(), let reloadAfterDate = reloadDate.afterMinuteDate(minute: 15) {
                    toastView(view: self.view, message: "\(reloadAfterDate.toString(format: "MM-dd HH:mm")) 후에 다시 시도하세요.")
                }
            }

            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.refreshControl.indicator.stop()
                self.tableView.contentOffset = CGPoint(x: 0, y: 0)
                self.tableView.reloadData()
            }
        }

        viewModel.onUpdate = {
            self.tableView.reloadData()
        }
    }

    private func setView() {
        let tab = UITapGestureRecognizer(target: self, action: #selector(settingLocation(_:)))
        let tab3 = UITapGestureRecognizer(target: self, action: #selector(settingLocation(_:)))
        titleLabel.addGestureRecognizer(tab)
        titleLabel.isUserInteractionEnabled = true
        locationImageView.addGestureRecognizer(tab3)
        locationImageView.isUserInteractionEnabled = true

        tableView.register(UINib(nibName: BriefingTableViewCell.cellIdentifier, bundle: nil),
                           forCellReuseIdentifier: BriefingTableViewCell.cellIdentifier)
        tableView.register(UINib(nibName: WeatherTableViewCell.cellIdentifier, bundle: nil),
                           forCellReuseIdentifier: WeatherTableViewCell.cellIdentifier)
        tableView.register(UINib(nibName: TimeWeatherDetailTableViewCell.cellIdentifier, bundle: nil),
                           forCellReuseIdentifier: TimeWeatherDetailTableViewCell.cellIdentifier)
        tableView.register(UINib(nibName: DustTableViewCell.cellIdentifier, bundle: nil),
                           forCellReuseIdentifier: DustTableViewCell.cellIdentifier)
        tableView.register(UINib(nibName: ScheduleDetailTableViewCell.cellIdentifier, bundle: nil),
                           forCellReuseIdentifier: ScheduleDetailTableViewCell.cellIdentifier)

        locationImageView.image =  UIImage.init(icon: .fontAwesomeSolid(.checkCircle),
                                                size: locationImageView.frame.size,
                                                textColor: AppColorList().textColorLightGray,
                                                backgroundColor: .clear)
        titleLabel.font = UIFont(fontsStyle: .regular, size: 18.0)

        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        // refreshControl.indicator.lineColor = .white
        tableView.addSubview(refreshControl)

        bannerADView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        // bannerAdView.rootViewController = self
        bannerADView.delegate = self
        bannerADView.isUserInteractionEnabled = true
        bannerRequest()
        tableView.reloadData()
    }

}

// MARK: - extensions
extension CareViewController {
    private func updateNaviTitleName() {
        if globalLocationIndex > 0 {
            // 위치 지정 설정
            let locationData = try! Realm().objects(RLMLocationSettingInfo.self).filter("idx = %d", globalLocationIndex)
            if locationData.count > 0 {
                globalLon = "\(locationData[0].wgs84Lon)"
                globalLat = "\(locationData[0].wgs84Lat)"
                self.titleLabel.text = locationData[0].addressName
            } else {
                // 예외 처리...
                globalLon = String(AppInfoManager.shared.currentLocation.longitude)
                globalLat = String(AppInfoManager.shared.currentLocation.latitude)
            }
        }
    }

    @objc func onRefreshData() {
        self.tableView.contentOffset = CGPoint(x: 0, y: 0)
        self.tableView.contentOffset = CGPoint(x: 0, y: -60)
        self.refreshControl.indicator.start()
        self.onRefresh()
    }

    @objc func onRefresh() {
        if globalLocationIndex == 0 {
            // 현재 위치
            AppInfoManager.shared.getUserLocation { (success) in
                if success {
                    DLog("위치정보 가져오기 성공!!!")
                } else {
                    DLog("위치정보 가져오기 실패!!!")
                    toastView(view: self.view,
                              message: "위치를 가져오는데 실패하였습니다.\n기본 설정된 설정값을 사용합니다.",
                              duration: 3.0,
                              position: .bottom,
                              title: nil)
                }

                globalLon = String(AppInfoManager.shared.currentLocation.longitude)
                globalLat = String(AppInfoManager.shared.currentLocation.latitude)
                AppInfoManager.shared.getLocationAddress(location: AppInfoManager.shared.currentLocation) { (adress) in
                    self.titleLabel.text = adress
                }
                self.viewModel.getWeatherData(query: .forecast(query: "\(globalLat),\(globalLon)", days: "3"))
            }
        } else {
            let locationData = try! Realm().objects(RLMLocationSettingInfo.self).filter("idx = %d", globalLocationIndex)
            if locationData.count > 0 {
                globalLon = "\(locationData[0].wgs84Lon)"
                globalLat = "\(locationData[0].wgs84Lat)"
                viewModel.getWeatherData(query: .forecast(query: "\(globalLat),\(globalLon)", days: "3"))
            }
        }
    }

    @objc func settingLocation(_ sender: UITapGestureRecognizer) {
        let identifier = "LocationNavigationControllerSID"
        let locationSettingVC = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! LocationNavigationController
        locationSettingVC.modalPresentationStyle = .fullScreen
        self.present(locationSettingVC, animated: true, completion: nil)
    }

    @objc func moveMoreView(_ sender: UIButton) {
        let identifier = "ScheduleDetailMainViewControllerSID"
        let scheduleVC = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! ScheduleDetailMainViewController
        self.navigationController?.pushViewController(scheduleVC, animated: true)
   }
}

extension CareViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sectionArray[section]
        switch sectionType {
            case .briefing:
                return 1
            case .schedule:
                return (viewModel.scheduleList?.count ?? 0 > 0 ? viewModel.scheduleList!.count : 1)
            case .dayWeather:
                return 1
            case .timeWeather:
                return (viewModel.homeForcastData.count > 0 ? viewModel.homeForcastData.count : 1)
            case .dustInfo:
                return (viewModel.currentData?.air_quality != nil ? 1 : 1)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = sectionArray[indexPath.section]
        switch sectionType {
            case .briefing:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: BriefingTableViewCell.cellIdentifier) as? BriefingTableViewCell else { return UITableViewCell() }
                cell.setData(viewModel: viewModel)
                return cell
            case .schedule:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleDetailTableViewCell.cellIdentifier) as? ScheduleDetailTableViewCell else { return UITableViewCell() }
                cell.bottomLineView.isHidden = true
                if viewModel.scheduleList?.count ?? 0 > 0, let data = viewModel.scheduleList?[indexPath.row] {
                    cell.setData(data: data)
                    if (viewModel.scheduleList?.count ?? 0 - 1) == indexPath.row {
                        cell.bottomLineView.isHidden = false
                    }
                } else {
                    // 일정이 없을때
                    cell.bottomLineView.isHidden = false
                    if viewModel.childInfoList?.count ?? 0 == 0 {
                        cell.noneData(chileFlag: true)
                    } else {
                        cell.noneData(chileFlag: false)
                    }
                }
                return cell
            case .dayWeather:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.cellIdentifier) as? WeatherTableViewCell else { return UITableViewCell() }
                guard let currentData = viewModel.currentData else {
                    cell.slide()
                    return cell
                }
                cell.setData(data: currentData)
                return cell
            case .timeWeather:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeWeatherDetailTableViewCell.cellIdentifier) as? TimeWeatherDetailTableViewCell else { return UITableViewCell() }
                guard viewModel.homeForcastData.count > indexPath.row else {
                    cell.slide()
                    return cell
                }
                cell.setData(data: viewModel.homeForcastData[indexPath.row])
                if (viewModel.homeForcastData.count - 1) == indexPath.row {
                    cell.bottomLineView.isHidden = false
                } else {
                    cell.bottomLineView.isHidden = true
                }
                return cell
            case .dustInfo:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DustTableViewCell.cellIdentifier) as? DustTableViewCell else { return UITableViewCell() }
                guard let airQuality = viewModel.currentData?.air_quality else { return cell }
                cell.setData(data: airQuality)
                return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionType = sectionArray[indexPath.section]
        switch sectionType {
        case .briefing:
            break
        case .schedule:
            if viewModel.childInfoList?.count ?? 0 == 0 {
                // 등록된 아이정보가 없을때 정보 화면으로 이동
                if let childInfoView = self.storyboard?.instantiateViewController(withIdentifier: "ChildSettingViewControllerSID") as? ChildSettingViewController {
                   self.navigationController?.pushViewController(childInfoView, animated: true)
                }
            } else {
                if viewModel.scheduleList?.count ?? 0 > 0, let _ = viewModel.scheduleList?[indexPath.row] {
                    let scheduleDetailView = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleDetailMainViewControllerSID") as! ScheduleDetailMainViewController
                    self.navigationController?.pushViewController(scheduleDetailView, animated: true)
                }
            }
        case .dayWeather:
            break
        case .timeWeather:
            let detailView = self.storyboard?.instantiateViewController(withIdentifier: "WeatherTimeViewControllerSID") as! WeatherTimeViewController
            detailView.viewModel.setHourData(datas: viewModel.forecastData)
            self.navigationController?.pushViewController(detailView, animated: true)
            break
        case .dustInfo:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: (8 + 10)))
        footerView.backgroundColor = .clear
        let bottomView = UIView(frame: CGRect(x: 10.0, y: 0.0, width: (tableView.frame.size.width - 20), height: 10))
        bottomView.backgroundColor = AppColorList().tableCellBgColor
        bottomView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
        footerView.addSubview(bottomView)

        if section == (sectionArray.count - 1) {
            footerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: (10 + 116))
            let bannerBoxView = ADBoxFooterView(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 116), type: .small(width: 320, height: 50))
            bannerBoxView.bannerFrameView.addSubview(bannerADView)
            footerView.addSubview(bannerBoxView)
        }
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (sectionArray.count - 1) {
            return (10 + 116)
        }
        return (8 + 10)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionType = sectionArray[section]
        if sectionType == .briefing {
            return 50
        }
        return 40
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionType = sectionArray[section]
        switch sectionType {
            case .dayWeather:
                let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 40.0))
                headerView.backgroundColor = .clear
                let label = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: (headerView.frame.size.width-20), height: 40.0))
                label.font = UIFont(fontsStyle: .regular, size: 14.0)
                label.textColor = AppColorList().textColorDarkText
                label.backgroundColor = AppColorList().tableCellBgColor
                label.text =  "  현재 날씨"

                label.roundCorners(corners: [.topRight, .topLeft], radius: 5)
                headerView.addSubview(label)
                let subLabel = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: (headerView.frame.size.width-30), height: 40.0))
                subLabel.font = UIFont(fontsStyle: .regular, size: 10.0)
                subLabel.textColor = AppColorList().textColorLightGray
                subLabel.backgroundColor = .clear
                subLabel.textAlignment = .right

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                if viewModel.currentData != nil {
                    if let dateValue = dateFormatter.date(from: viewModel.currentData?.last_updated ?? "") {
                        dateFormatter.dateFormat = "MM월 dd일 HH시 mm분 기준"
                        subLabel.text = dateFormatter.string(from: dateValue)
                    }
                }
                headerView.addSubview(subLabel)
                let lineView = UIView(frame: CGRect(x: 10.0, y: 40.0, width: (tableView.frame.size.width - 20), height: 1))
                lineView.backgroundColor = AppColorList().lineColor
                headerView.addSubview(lineView)
                return headerView
            case .schedule, .timeWeather, .dustInfo, .briefing:
                let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: (sectionType == .briefing ? 50.0 : 40.0) ))
                headerView.backgroundColor = .clear
                let label = UILabel(frame: CGRect(x: 10.0, y: (sectionType == .briefing ? 10.0 : 0.0), width: (headerView.frame.size.width-20), height: 40.0))
                label.font = UIFont(fontsStyle: .regular, size: 14.0)
                label.textColor = AppColorList().textColorDarkText
                label.backgroundColor = AppColorList().tableCellBgColor
                headerView.addSubview(label)
                if sectionType == .schedule {
                    if viewModel.childInfoList?.count ?? 0 > 0, let data = viewModel.childInfoList?.first {
                        label.text = "  " + String(format: sectionType.rawValue, data.name)
                    } else {
                        label.text = "  일정"
                    }
                } else {
                    label.text = "  " + sectionType.rawValue
                }
                label.roundCorners(corners: [.topRight, .topLeft], radius: 5)

                if sectionType == .dustInfo {
                    let subLabel = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: (headerView.frame.size.width-30), height: 40.0))
                    subLabel.font = UIFont(fontsStyle: .regular, size: 10.0)
                    subLabel.textColor = AppColorList().textColorLightGray
                    subLabel.backgroundColor = .clear
                    subLabel.textAlignment = .right
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    if viewModel.currentData != nil {
                        if let dateValue = dateFormatter.date(from: viewModel.currentData?.last_updated ?? "") {
                            dateFormatter.dateFormat = "MM월 dd일 HH시 기준"
                            subLabel.text = dateFormatter.string(from: dateValue)
                        }
                    }
                    headerView.addSubview(subLabel)
                }
                let lineView = UIView(frame: CGRect(x: 10.0, y: (sectionType == .briefing ? 50.0 : 40.0), width: (tableView.frame.size.width - 20), height: 1))
                lineView.backgroundColor = AppColorList().lineColor
                headerView.addSubview(lineView)
                return headerView
        }
    }
}

extension CareViewController: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        
    }

    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        DLog("\(tipView) did dismiss!")
        locationTipView?.dismiss {
            self.locationTipView = nil
            // 팝업을 열지 않는다...
            saveTipViewOpenFlag(keyName: .hospViewTipFlag, flag: true)
        }
    }
}

extension CareViewController: AdFitBannerAdViewDelegate {
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

//
//  WeatherTimeViewController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/01/21.
//  Copyright © 2022 Apps Studio. All rights reserved.
//

import UIKit
import AdFitSDK

final class WeatherTimeViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let bannerADView = AdFitBannerAdView(clientId: "clientId", adUnitSize: "320x50")
    var viewModel = WeatherTimeViewModel()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        setViewModel()
        setNaviView()
        setView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding  = 0
            tableView.fillerRowHeight = 0
        }
    }

    // MARK: - functions

    private func setViewModel() {
        viewModel.onUpdate = {
            self.tableView.reloadData()
        }
    }

    private func setNaviView() {
        backButton.setImage(globalBackBtImage, for: .normal)
        backButton.tintColor       = AppColorList().naviTitleColor
        backButton.imageEdgeInsets = globalBackBtEdgeInsets
        titleLabel.font = UIFont(fontsStyle: .regular, size: 18.0)
    }

    private func setView() {
        tableView.register(UINib(nibName: TimeWeatherDetailTableViewCell.cellIdentifier, bundle: nil),
                           forCellReuseIdentifier: TimeWeatherDetailTableViewCell.cellIdentifier)
        bannerADView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        bannerADView.delegate = self
        bannerADView.isUserInteractionEnabled = true
        bannerRequest()
        tableView.reloadData()

        AnalyticsManager.shared.screenName(screenName:"시간별 날씨 상세화면", screenClass: "WeatherTimeDetailView")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

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
            tableView.reloadData()
        }
    }

}

// MARK: - extensions
// MARK: - UITableViewDelegate, UITableViewDataSource
extension WeatherTimeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel.forecastData.count > section else { return 0 }
        return viewModel.forecastData[section].hour.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.forecastData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeWeatherDetailTableViewCell.cellIdentifier) as? TimeWeatherDetailTableViewCell else { return UITableViewCell() }
        guard viewModel.forecastData[indexPath.section].hour.count > indexPath.row else {
            cell.slide()
            return cell
        }
        cell.setData(data: viewModel.forecastData[indexPath.section].hour[indexPath.row])
        if (viewModel.forecastData[indexPath.section].hour.count - 1) == indexPath.row {
            cell.bottomLineView.isHidden = false
        } else {
            cell.bottomLineView.isHidden = true
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (viewModel.forecastData.count - 1) == section {
            return (8 + 10 + 70)
        } else if section == 0 {
            return (10 + 108)
        } else {
            return (10 + 8)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: (8 + 10)))
        footerView.backgroundColor = .clear
        let bottomView = UIView(frame: CGRect(x: 10.0, y: 0.0, width: (tableView.frame.size.width - 20), height: 10))
        bottomView.backgroundColor = AppColorList().tableCellBgColor
        bottomView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
        footerView.addSubview(bottomView)

        if section == 0 {
            footerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: (10 + 108))
            let bannerBoxView = ADBoxFooterView(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 108), type: .small(width: 320, height: 50))
            bannerBoxView.bannerFrameView.addSubview(bannerADView)
            footerView.addSubview(bannerBoxView)
        } else if (viewModel.forecastData.count - 1) == section {
            footerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: (8 + 10 + 70))
            let label = UILabel(frame: CGRect(x: 16.0, y: (8 + 10 + 10), width: (footerView.frame.size.width-32), height: 50.0))
            label.font = UIFont(fontsStyle: .regular, size: 10.0)
            label.textColor = AppColorList().textColorLightGray
            label.backgroundColor = .clear
            label.numberOfLines = 0
            label.lineBreakMode = .byCharWrapping
            label.text = "WeatherAPI를 사용하였습니다. 기상 상황에 따라서 실제 날씨와 다를 수 있습니다."
            footerView.addSubview(label)
            return footerView
        }
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return timeWeatherDetailTHeaderViewHeight
        }
        return (timeWeatherDetailTHeaderViewHeight - 10)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TimeWeatherDetailHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: (section == 0 ? timeWeatherDetailTHeaderViewHeight : (timeWeatherDetailTHeaderViewHeight - 10))))
        header.updateHeaderView(data: viewModel.forecastData[section])
        return header
    }
}

extension WeatherTimeViewController: AdFitBannerAdViewDelegate {
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

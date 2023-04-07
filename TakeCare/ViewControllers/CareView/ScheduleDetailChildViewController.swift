//
//  ScheduleDetailChildViewController.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2020/02/11.
//  Copyright © 2020 Apps Studio. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RealmSwift

class ScheduleDetailChildViewController: UIViewController, IndicatorInfoProvider {
    let bannerADView = AdFitBannerAdView(clientId: "clientId", adUnitSize: "320x50")
    var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = AppColorList().tableBgColor

        tv.register(UINib(nibName: ScheduleDetailTableViewCell.cellIdentifier, bundle: nil),
                    forCellReuseIdentifier: ScheduleDetailTableViewCell.cellIdentifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = true
        tv.separatorStyle = .none
        tv.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv.separatorColor = .clear
        return tv
    }()
    
    var itemInfo: IndicatorInfo?
    var babyData: RLMChildInfo?
    var scheduleList: Results<RLMChildVCNScheduleInfo>? = nil
    let realm: Realm = try! Realm()
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo!
    }
    
    init(data: RLMChildInfo) {
        self.itemInfo = IndicatorInfo(title: data.name)
        self.babyData = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
        
        tableView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bannerADView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        bannerADView.delegate = self
        bannerADView.isUserInteractionEnabled = true
        bannerRequest()
        
        guard let info = babyData else { return }
        // 현재 진행중인 일정과 한달 후에 일정을 보여준다.
        scheduleList = realm.objects(RLMChildVCNScheduleInfo.self).filter("childIdx = %d AND endDate >= %@", info.idx, Date()).sorted(byKeyPath: "startDate", ascending: true)
        if scheduleList?.count ?? 0 > 0 {
            tableView.reloadData()
        }
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

extension ScheduleDetailChildViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (scheduleList?.count ?? 0 > 0 ? scheduleList!.count : 1)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleDetailTableViewCell.cellIdentifier) as? ScheduleDetailTableViewCell else { return UITableViewCell() }
        if scheduleList?.count ?? 0 > 0, let data = scheduleList?[indexPath.row] {
            cell.setData(data: data)
        } else {
            // 일정이 없을때
            cell.noneData(chileFlag: false)
        }
        cell.bottomLineView.isHidden = false
        if indexPath.row == 0 {
            cell.bottomLineView.isHidden = true
            cell.boxView.roundCorners(corners: [.topLeft, .topRight], radius: 5)
        } else if (scheduleList!.count - 1) == indexPath.row {
            cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
        } else {
            cell.boxView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        if scheduleList?.count ?? 0 > 0, let data = scheduleList?[indexPath.row] {
            if let message = SQLiteManager.shared.getVcnInfoMessgae(query: "SELECT * FROM VCN_INFO WHERE VCNCD = \(data.vcnCD)") {
                // 등록된 예방접종 `데이터가 있다면..
                let alert = UIAlertController(style: .actionSheet)
                alert.addTextViewer(text: .text(message))
                alert.addAction(title: "닫기", style: .cancel)
                alert.show()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 108
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let bannerBoxView = ADBoxFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 108), type: .small(width: 320, height: 50))
        bannerBoxView.bannerFrameView.addSubview(bannerADView)
        return bannerBoxView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension ScheduleDetailChildViewController: AdFitBannerAdViewDelegate {
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

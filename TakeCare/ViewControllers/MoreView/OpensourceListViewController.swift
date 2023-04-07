//
//  OpensourceListViewController.swift
//  TakeCare
//
//  Created by Lim on 09/08/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

class OpenSourceInfo: Decodable {
    var name: String = ""
    var url: String = ""

    private enum CodingKeys: String, CodingKey {
        case name, url
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        url  = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
    }
}

class OpensourceListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var titleName: String?
    var openSourceList: [OpenSourceInfo] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "MoreViewTableViewCell", bundle: nil), forCellReuseIdentifier: "MoreViewTableViewCell")

        backButton.setImage(globalBackBtImage, for: .normal)
        backButton.tintColor       = AppColorList().naviTitleColor
        backButton.imageEdgeInsets = globalBackBtEdgeInsets
        titleLabel.font            = UIFont(fontsStyle: .regular, size: 18.0)
        titleLabel.text            = titleName
        
        if let path = Bundle.main.path(forResource: "opensource", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: json)
                if let list = try? JSONDecoder().decode([OpenSourceInfo].self, from: jsonData) {
                    self.openSourceList = list
                    self.tableView.reloadData()
                }
            } catch let error {
                DLog("parse error: \(error.localizedDescription)")
                self.backView(self.backButton)
            }
        } else {
            self.backView(self.backButton)
        }
        AnalyticsManager.shared.screenName(screenName: "오픈소스 리스트 화면", screenClass: "OpensourceListView")
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
    
    @IBAction func backView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

extension OpensourceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openSourceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoreViewTableViewCell") as? MoreViewTableViewCell else { return UITableViewCell() }
        
        cell.menuArrowImageView.image = UIImage.init(icon: .googleMaterialDesign(.keyboardArrowRight), size: CGSize(width: (cell.menuArrowImageView.frame.size.width), height: (cell.menuArrowImageView.frame.size.height)), textColor:AppColorList().textColorLightGray, backgroundColor: .clear)
        cell.menuTitleLabel.text = openSourceList[indexPath.row].name
        cell.menuSubTitleLabel.isHidden = false
        cell.menuSubTitleLabel.text = ""
        cell.menuArrowImageView.isHidden = false
        cell.menuBottomLine.isHidden = false
        cell.boxView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
        if (openSourceList.count - 1) == indexPath.row {
            cell.menuBottomLine.isHidden = true
            cell.boxView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5)
        } else if indexPath.row == 0 {
            cell.boxView.roundCorners(corners: [.topLeft, .topRight], radius: 5)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStroyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let moreView = mainStroyboard.instantiateViewController(withIdentifier: "WebViewControllerSID") as? WebViewController {
            moreView.urlLink = openSourceList[indexPath.row].url
            moreView.moreMenuType = nil
            moreView.titleName = openSourceList[indexPath.row].name
            self.navigationController?.pushViewController(moreView, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

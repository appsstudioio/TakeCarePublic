//
//  AddressSearchViewController.swift
//  TakeCare
//
//  Created by Lim on 05/08/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class AddressSearchViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    private var observation: NSKeyValueObservation? = nil
    
    var webView: WKWebView?
    weak var ower: LocationAddViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backButton.setImage(globalBackBtImage, for: .normal)
        backButton.tintColor       = AppColorList().naviTitleColor
        backButton.imageEdgeInsets = globalBackBtEdgeInsets
        titleLabel.font = UIFont(fontsStyle: .regular, size: 18.0)
        AnalyticsManager.shared.screenName(screenName: "주소 검색 화면", screenClass: "AddressSearchView")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.observation = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let contentController = WKUserContentController()
        contentController.add(self, name: "callBackHandler")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: subView.bounds, configuration: config)
        self.subView.addSubview(webView!)
        webView?.navigationDelegate = self
        
        loadWebView()
        
        guard observation == nil else { return }
        observation = webView?.observe(\.estimatedProgress, options: [.new]) { _, _ in
            self.progressView.progress = Float(self.webView?.estimatedProgress ?? 0)
            if self.webView?.estimatedProgress == 1.0 {
             DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                     self.progressView.isHidden = true
                }
            } else {
                self.progressView.isHidden = false
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func loadWebView() {
        if let url = URL(string: "https://appsstudioio.github.io/" + urlList().addressSearchWebLink) {
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            webView?.load(request)
        }
    }
    @IBAction func backView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - WKWebView Delegate
extension AddressSearchViewController: WKNavigationDelegate, WKScriptMessageHandler, SFSafariViewControllerDelegate {
    private func replaceAddress(addr: String) -> String {
        let tempArry = addr.components(separatedBy: " ")
        if tempArry.count > 0 {
            var tempString = tempArry.first!
            if tempString.count <= 2 {
                tempString = tempString.replacingOccurrences(of: "서울", with: "서울특별시")
                tempString = tempString.replacingOccurrences(of: "강원", with: "강원도")
                tempString = tempString.replacingOccurrences(of: "경기", with: "경기도")
                tempString = tempString.replacingOccurrences(of: "인천", with: "인천광역시")
                tempString = tempString.replacingOccurrences(of: "울산", with: "울산광역시")
                tempString = tempString.replacingOccurrences(of: "경북", with: "경상북도")
                tempString = tempString.replacingOccurrences(of: "경남", with: "경상남도")
                tempString = tempString.replacingOccurrences(of: "충북", with: "충청북도")
                tempString = tempString.replacingOccurrences(of: "충남", with: "충청남도")
                tempString = tempString.replacingOccurrences(of: "전북", with: "전라북도")
                tempString = tempString.replacingOccurrences(of: "전남", with: "전라남도")
                tempString = tempString.replacingOccurrences(of: "대전", with: "대전광역시")
                tempString = tempString.replacingOccurrences(of: "광주", with: "광주광역시")
                tempString = tempString.replacingOccurrences(of: "대구", with: "대구광역시")
                tempString = tempString.replacingOccurrences(of: "부산", with: "부산광역시")
            }

            for idx in 1..<tempArry.count {
                tempString += " " + tempArry[idx]
            }
            return tempString
        }
        return addr
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "callBackHandler" {
            if let postCodData = message.body as? [String: Any] {
                DLog("postCodData : \(postCodData)")
                var addr = postCodData["addr"] as! String
                addr = replaceAddress(addr: addr)
                
                let searchKeyword = postCodData["searchKeyword"] as! String
//                let data = postCodData["data"] as! [String: AnyObject]
//                let addrEng = data["addressEnglish"] as! String
                // 검색어 로그 남김..
                AnalyticsManager.shared.eventLoging(logType: .search, itemID: searchKeyword)

                AppInfoManager.shared.getAddressLocation(address: addr) { (placemarks, status) in
                    if status == true, placemarks!.count > 0 {
                        let placeMark = placemarks![0]
                        DLog("placeMark : \(placeMark)")
                        self.backView(self.backButton)
                        self.ower?.setMarker(location: placeMark.location!.coordinate, address: addr)
                        
                    }
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        startAnimationIndicator()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        stopAnimationIndicator()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DLog(error)
//        stopAnimationIndicator()
        UIAlertController.showAlert("알림", "페이지 연결에 실패하였습니다.\n다시 시도해 주세요.", self, { (_) in
            // self.backView(nil)
        })
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

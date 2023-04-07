//
//  WebViewController.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class WebViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webToolbarHeightConstr: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    private var observation: NSKeyValueObservation? = nil
    
    @IBOutlet weak var preBarButton: UIBarButtonItem!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var reloadBarButton: UIBarButtonItem!
    @IBOutlet weak var naviHeightConstraint: NSLayoutConstraint!
    
    var urlLink: String?
    var titleName: String?
    var moreMenuType: MoreSubMenuName?
    var preScrollViewOffsetY: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.delegate = self
        
        // Do any additional setup after loading the view.
        if moreMenuType != nil {
            if moreMenuType == .devBlog {
                AnalyticsManager.shared.screenName(screenName: "개발자 블로그 화면", screenClass: "WebDevBlogView")
                titleLabel.text = NSLocalizedString("devBlog", comment: "")
            } else if moreMenuType == .openSource {
                titleLabel.text = NSLocalizedString("openSource", comment: "")
                webToolbarHeightConstr.constant = 0.0
            } else if moreMenuType == .qnaMail {
                AnalyticsManager.shared.screenName(screenName: "제안하기 화면", screenClass: "WebQnAView")
                titleLabel.text = NSLocalizedString("qnaMail", comment: "")
            } else if moreMenuType == .policy {
                AnalyticsManager.shared.screenName(screenName: "개인정보 처리방침 화면", screenClass: "WebPolicyView")
                titleLabel.text = NSLocalizedString("policy", comment: "")
            }
        } else {
            titleLabel.text = titleName
        }
        
        backButton.setImage(globalBackBtImage, for: .normal)
        backButton.tintColor       = AppColorList().naviTitleColor
        backButton.imageEdgeInsets = globalBackBtEdgeInsets
        titleLabel.font = UIFont(fontsStyle: .regular, size: 18.0)
        
        preBarButton.setIcon(icon: .googleMaterialDesign(.arrowBack), iconSize: 20, color: AppColorList().naviTitleColor)
        nextBarButton.setIcon(icon: .googleMaterialDesign(.arrowForward), iconSize: 20, color: AppColorList().naviTitleColor)
        reloadBarButton.setIcon(icon: .googleMaterialDesign(.refresh), iconSize: 20, color: AppColorList().naviTitleColor)
        
        observation = webView.observe(\.estimatedProgress, options: [.new]) { _, _ in
           self.progressView.progress = Float(self.webView.estimatedProgress)
           if self.webView.estimatedProgress == 1.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.progressView.isHidden = true
               }
           } else {
               self.progressView.isHidden = false
           }
       }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadWebView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        stopAnimationIndicator()
        self.observation = nil
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
    
    func loadWebView() {
        if moreMenuType == .openSource {
            let htmlPath = Bundle.main.path(forResource: "opensource", ofType: "html")
            let url = URL(fileURLWithPath: htmlPath!)
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            if let url = URL(string: urlLink ?? "") {
                var request = URLRequest(url: url)
                request.timeoutInterval = 30
                webView.load(request)
            }
        }
    }
    
    @IBAction func backView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        webView.goForward()
    }
    
    @IBAction func prevBtn(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            loadWebView()
        }
    }
    
    @IBAction func reloadBtn(_ sender: Any) {
        webView.reload()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DLog("\(preScrollViewOffsetY) : \(scrollView.contentOffset.y)")
        /*
        let offsetY = scrollView.contentOffset.y
        UIView.animate(withDuration: 10.0,
                       delay: 2.0,
                       usingSpringWithDamping: 30.0,
                       initialSpringVelocity: 30.0,
                       options: .preferredFramesPerSecond60,
                       animations: {
            if offsetY <= 0 {
                self.naviHeightConstraint.constant = 60
            } else if self.preScrollViewOffsetY < offsetY {
                self.naviHeightConstraint.constant = 0
            } else {
                let moveOffsetY = (self.naviHeightConstraint.constant + (self.preScrollViewOffsetY - offsetY))
                self.naviHeightConstraint.constant = (moveOffsetY <= 60 && moveOffsetY >= 0) ? moveOffsetY : 60
            }
        }, completion: nil)
        preScrollViewOffsetY = scrollView.contentOffset.y
         */
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, SFSafariViewControllerDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    // MARK: - WKWebView Delegate
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        UIAlertController.showAlert("알림", message, self)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let longPress = UILongPressGestureRecognizer(target: self, action: nil)
        longPress.allowableMovement = 100
        longPress.minimumPressDuration = 0.3
        longPress.delaysTouchesBegan = true
        longPress.delaysTouchesEnded = true
        longPress.cancelsTouchesInView = true
        webView.addGestureRecognizer(longPress)
        webView.scrollView.addGestureRecognizer(longPress)
        
        webView.allowsBackForwardNavigationGestures = false
        
        let cssString = "* { -webkit-touch-callout: none; -webkit-user-select: none; -webkit-tap-highlight-color: rgba(0,0,0,0); } input,textarea { -webkit-touch-callout: default; !important; -webkit-user-select: text; !important; }"
        let javascriptString = "var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)"
        let javascriptWithCSSString = String(format: javascriptString, cssString)
        webView.evaluateJavaScript(javascriptWithCSSString, completionHandler: { (result, error) in
            if error != nil {
                DLog(result ?? "")
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        DLog("detailView :  \(String(describing: navigationAction.request.url?.absoluteString))")
        
        #if true
        decisionHandler(.allow)
        #else
        let url = navigationAction.request.url
        
        if requestUrl?.host == url?.host {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            if url?.host?.isEmpty == false && firstFlag == false {
                let safariView = SFSafariViewController(url: url!)
                self.present(safariView, animated: true, completion: nil)
            }
        }
        #endif
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DLog(error)
        UIAlertController.showAlert("알림", "페이지 연결에 실패하였습니다.\n다시 시도해 주세요.", self, { (_) in
            // self.backView(nil)
        })
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//
//  WebViewController.swift
//  Commun
//
//  Created by Chung Tran on 8/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    lazy var webView: WKWebView! = {
        let webConfig = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webView.showLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.hideLoading()
        webView.parentViewController?.title = webView.title
        // disable horizontal scrolling
        let scrollableSize = CGSize(width: view.frame.size.width, height: webView.scrollView.contentSize.height)
        self.webView?.scrollView.contentSize = scrollableSize
    }
}

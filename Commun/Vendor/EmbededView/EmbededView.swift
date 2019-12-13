//
//  EmbededView.swift
//  Commun
//
//  Created by Chung Tran on 17/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import CyberSwift

class EmbededView: UIView {
    var bag = DisposeBag()
    
    func setUpWithEmbeded(_ embededResult: ResponseAPIContentEmbedResult?){
        if embededResult?.type == "video",
            let html = embededResult?.html {
            showWebView(with: html)
        } else if embededResult?.type == "photo",
            let urlString = embededResult?.url,
            let url = URL(string: urlString) {
            
            if urlString.lowercased().ends(with: ".gif") {
                showWebView(with: "<div><div style=\"left: 0; width: 100%; height: 0; position: relative; padding-bottom: 74.9457%;\"><img src=\"\(urlString)\" /></div></div>")
            } else {
                showPhoto(with: url)
            }
        } else {
            adjustHeight(withHeight: 0)
        }
    }
    
    func showWebView(with htmlString: String) {
        var webView: HTMLStringWebView!
        
        if let currentWebView = subviews.first(where: {$0 is HTMLStringWebView}) as? HTMLStringWebView {
            webView = currentWebView
        } else {
            removeSubviews()
            webView = HTMLStringWebView()
            webView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(webView)
            webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            webView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            
            webView.scrollView.contentInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.bouncesZoom = false
            
            showLoading()
            webView.navigationDelegate = self
        }
        
        webView.load(htmlString: htmlString, baseURL: nil)
    }
    
    func showPhoto(with url: URL) {
        removeSubviews()
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.addTapToViewer()
        
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        imageView.showLoading()
        
        imageView.sd_setImage(with: url) { [weak self] (image, _, _, _) in
            guard let strongSelf = self else {return}
            var image = image
            if image == nil {
                image = UIImage(named: "image-not-found")
                imageView.image = image
            }
            strongSelf.adjustHeight(withHeight: strongSelf.size.width * image!.size.height / image!.size.width)
        }
    }
    
    private func adjustHeight(withHeight height: CGFloat) {
        self.heightConstraint?.constant = height
        hideLoading()
        self.setNeedsLayout()
//        self.didShowContentWithHeight.onNext(height)
    }
}


// MARK: - WKNavigationDelegate
extension EmbededView: WKNavigationDelegate {
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Logger.log(message: #function, event: .debug)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Logger.log(message: #function, event: .debug)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.log(message: #function, event: .debug)
        let height = (UIScreen.main.bounds.width - 16) * webView.height / webView.width
        adjustHeight(withHeight: height)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Logger.log(message: #function, event: .debug)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.log(message: #function, event: .debug)
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        Logger.log(message: #function, event: .debug)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.log(message: #function, event: .debug)
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        Logger.log(message: #function, event: .debug)
        completionHandler(.performDefaultHandling,nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        Logger.log(message: #function, event: .debug)
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        Logger.log(message: #function, event: .debug)
        decisionHandler(.allow)
    }
}

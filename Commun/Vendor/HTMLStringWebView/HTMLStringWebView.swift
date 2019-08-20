//
//  HTMLWebView.swift
//  Commun
//
//  Created by Chung Tran on 24/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import WebKit

class HTMLStringWebView: UIWebView {
    var htmlString: String?
    override func loadHTMLString(_ string: String, baseURL: URL?) {
        guard htmlString != string else {return}
        htmlString = string
        
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"><link rel=\"stylesheet\" type=\"text/css\" href=\"HTMLStringWebView.css\"></HEAD><BODY>"
        let htmlEnd = "</BODY></HTML>"
        super.loadHTMLString(htmlStart + renderContent(html: string) + htmlEnd, baseURL: Bundle.main.bundleURL)
    }
    
    func renderContent(html: String) -> String {
        var result = html
        
        // Detect users
        #warning("Remove golos.io in production")
        // "(https:\\/\\/(?:golos\\.io|commun\\.com)\\/)?@\(String.nameRegex)"
        for mention in result.getMentions() {
            if let regex = try? NSRegularExpression(pattern: "\\s(?![\">])(https:\\/\\/(?:golos\\.io|commun\\.com)\\/)?@\(NSRegularExpression.escapedPattern(for: mention))(?![\"<])") {
                result = regex.stringByReplacingMatches(in: result, options: [], range: NSMakeRange(0, result.count), withTemplate: "<a href=\"https://commun.com/@\(mention)\">@\(mention)</a>")
            }
        }
        
        // Detect links
        let types = NSTextCheckingResult.CheckingType.link
        guard let detector = try? NSDataDetector(types: types.rawValue) else {
            return result
        }
        let matches = detector.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, result.count))
        
        for match in matches {
            guard let urlString = match.url?.absoluteString,
                let regex = try? NSRegularExpression(pattern: "(?![\">])\(NSRegularExpression.escapedPattern(for: urlString))(?![\"<])", options: .caseInsensitive)
                else {continue}
            // for images
            if urlString.ends(with: ".png", caseSensitive: false) ||
                urlString.ends(with: ".jpg", caseSensitive: false) ||
                urlString.ends(with: ".jpeg", caseSensitive: false) ||
                urlString.ends(with: ".gif", caseSensitive: false) {
                
                let resultTemplate = "<img src=\"\(urlString)\" />"
                
                if let regex1 = try? NSRegularExpression(pattern: "\\!?\\[.*\\]\\(\(NSRegularExpression.escapedPattern(for: urlString))\\)", options: .caseInsensitive) {
                    // TODO: Get description between "[" and "]"
                    result = regex1.stringByReplacingMatches(in: result, options: [], range: NSMakeRange(0, result.count), withTemplate: resultTemplate)
                }
                
                result = regex.stringByReplacingMatches(in: result, options: [], range: NSMakeRange(0, result.count), withTemplate: resultTemplate)
            } else {
                
                let resultTemplate = "<a href=\"\(urlString)\">\(urlString.removingPercentEncoding ?? urlString)</a>"
                
                if let regex1 = try? NSRegularExpression(pattern: "\\!?\\[.*\\]\\(\(NSRegularExpression.escapedPattern(for: urlString))\\)", options: .caseInsensitive) {
                    // TODO: Get description between "[" and "]"
                    result = regex1.stringByReplacingMatches(in: result, options: [], range: NSMakeRange(0, result.count), withTemplate: resultTemplate)
                }
                result = regex.stringByReplacingMatches(in: result, options: [], range: NSMakeRange(0, result.count), withTemplate: resultTemplate)
            }
        }
        return result
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        switch navigationType {
        case .linkClicked:
            // if userName tapped
            guard let url = request.url else {return false}
            let urlString = url.absoluteString
            
            if urlString.matches(pattern: "^\(NSRegularExpression.escapedPattern(for: "https://commun.com/"))\(String.mentionRegex)$"),
                let userName = urlString.components(separatedBy: "@").last {
                parentViewController?.showProfileWithUserId(userName)
                return false
            }
            
            
            let vc = UIViewController()
            parentViewController?.show(vc, sender: nil)
            vc.navigationController?.setNavigationBarHidden(false, animated: true)
            
            let webConfiguration = WKWebViewConfiguration()
            let webView = WKWebView(frame: .zero, configuration: webConfiguration)
            vc.view = webView
            webView.navigationDelegate = self
            webView.load(request)
            
            return false
        default:
            return true
        }
    }
}

extension HTMLStringWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webView.showLoading()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.hideLoading()
        webView.parentViewController?.title = webView.title
    }
}

//
//  HTMLWebView.swift
//  Commun
//
//  Created by Chung Tran on 24/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import WebKit
import Foundation
import SafariServices

class HTMLStringWebView: WKWebView {
    // MARK: - Properties
    var htmlString: String?
    
    // MARK: - Custom Functions
    func load(htmlString string: String, baseURL: URL?) {
        guard htmlString != string else { return }
        
        htmlString = string
        
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"><link rel=\"stylesheet\" type=\"text/css\" href=\"HTMLStringWebView.css\"></HEAD><BODY><section style=\"word-break: hyphenate; -webkit-hyphens: auto; font-family: -apple-system; text-align: justify; font-size: 17\">"
        let htmlEnd = " </section></BODY></HTML>"
        let html = htmlStart + string + htmlEnd
        
        super.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }
    
//    func renderContent(html: String) -> String {
//        var result = html
//
//        // Detect users
//        #warning("Remove golos.io in production")
//        // "(https:\\/\\/(?:golos\\.io|commun\\.com)\\/)?@\(String.nameRegex)"
//        for mention in result.getMentions() {
//            if let regex = try? NSRegularExpression(pattern: "\\s(?![\">])(https:\\/\\/(?:golos\\.io|commun\\.com)\\/)?@\(NSRegularExpression.escapedPattern(for: mention))(?![\"<])") {
//                result = regex.stringByReplacingMatches(in: result, options: [], range: NSMakeRange(0, result.count), withTemplate: "<a href=\"https://commun.com/@\(mention)\">@\(mention)</a>")
//            }
//        }
//
//        // parse links
//        result = stringByParsingLinks(html: result)
//
//        // replace characters
//        result = result.replacingOccurrences(of: "\n", with: "<br />")
//
//        return result
//    }
    
    func webView(_ webView: WKWebView, shouldStartLoadWith request: URLRequest, navigationType: WKNavigationType) -> Bool {
        switch navigationType {
        case .linkActivated:
            guard let url = request.url else { return false }
            let urlString = url.absoluteString
            
            // if userName tapped
            if urlString.removingPercentEncoding?.matches(pattern: "^\(NSRegularExpression.linkToMentionRegexPattern)$") == true,
                let userName = urlString.components(separatedBy: "@").last {
                parentViewController?.showProfileWithUserId(userName)
                return false
            }
                        
            let safariVC = SFSafariViewController(url: url)
            parentViewController?.present(safariVC, animated: true, completion: nil)
            
            return false
        default:
            return true
        }
    }
}

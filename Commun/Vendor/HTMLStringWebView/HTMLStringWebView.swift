//
//  HTMLWebView.swift
//  Commun
//
//  Created by Chung Tran on 24/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import WebKit
import SafariServices
import Down

class HTMLStringWebView: UIWebView {
    var htmlString: String?
    override func loadHTMLString(_ string: String, baseURL: URL?) {
        guard htmlString != string else {return}
        htmlString = string
        
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"><link rel=\"stylesheet\" type=\"text/css\" href=\"HTMLStringWebView.css\"></HEAD><BODY><section style=\"word-break: hyphenate; -webkit-hyphens: auto; font-family: -apple-system; text-align: justify; font-size: 17\">"
        let htmlEnd = " </section></BODY></HTML>"
        let down = Down(markdownString: string)
        
        let markdownToHTML = try? down.toHTML()
        let html = htmlStart + (markdownToHTML ?? "") + htmlEnd
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
            
            
            let safariVC = SFSafariViewController(url: url)
            parentViewController?.present(safariVC, animated: true, completion: nil)
            
            return false
        default:
            return true
        }
    }
}

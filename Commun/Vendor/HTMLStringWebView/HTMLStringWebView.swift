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

class HTMLStringWebView: UIWebView {
    var htmlString: String?
    override func loadHTMLString(_ string: String, baseURL: URL?) {
        guard htmlString != string else {return}
        htmlString = string
        
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"><link rel=\"stylesheet\" type=\"text/css\" href=\"HTMLStringWebView.css\"></HEAD><BODY>"
        let htmlEnd = "</BODY></HTML>"
        let html = htmlStart + renderContent(html: string) + htmlEnd
        super.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
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
        
        // parse links
        result = stringByParsingLinks(html: result)
        
        // replace characters
        result = result.replacingOccurrences(of: "\n", with: "<br />")
        
        return result
    }
    
    func stringByParsingLinks(html: String) -> String {
        var result = html
        // Detect links
        let types = NSTextCheckingResult.CheckingType.link
        guard let detector = try? NSDataDetector(types: types.rawValue) else {
            return result
        }
        let matches = detector.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, result.count))
        
        var originals = matches.map {
            result.nsString.substring(with: $0.range)
        }
        
        for (index, match) in matches.enumerated() {
            guard let urlString = match.url?.absoluteString else {continue}
            
            // for images
            if urlString.ends(with: ".png", caseSensitive: false) ||
                urlString.ends(with: ".jpg", caseSensitive: false) ||
                urlString.ends(with: ".jpeg", caseSensitive: false) ||
                urlString.ends(with: ".gif", caseSensitive: false) {
                
                if let regex1 = try? NSRegularExpression(pattern: "\\!?\\[.*\\]\\(\(NSRegularExpression.escapedPattern(for: originals[index]))\\)", options: .caseInsensitive) {
                    
                    let resultTemplate = { (_ embededString: String) -> String in
                        var description: String?
                        
                        if let match = embededString.range(of: "\\[.*\\]", options: .regularExpression) {
                            description = String(embededString[match]).replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                        }
                        
                        if let description = description, description.count > 0 {
                            return "<div class=\"embeded\"><img src=\"\(urlString)\" /><p>\(description)</p></div>"
                        }
                        
                        return "<img src=\"\(urlString)\" />"
                    }
                    
                    result = regex1.stringByReplacingMatches(in: result, templateForEach: resultTemplate)
                }
                
                if let regex = try? NSRegularExpression(pattern: "(?![\">])\(NSRegularExpression.escapedPattern(for: originals[index]))(?![\"<])", options: .caseInsensitive) {
                    
                    result = regex.stringByReplacingMatches(in: result, templateForEach: { (match) -> String in
                        return "<img src=\"\(urlString)\" />"
                    })
                }
                
            } else {
                if let regex1 = try? NSRegularExpression(pattern: "\\!?\\[.*\\]\\(\(NSRegularExpression.escapedPattern(for: originals[index]))\\)", options: .caseInsensitive) {
                    
                    let resultTemplate = { (_ embededString: String) -> String in
                        var description: String?
                        
                        if let match = embededString.range(of: "\\[.*\\]", options: .regularExpression) {
                            description = String(embededString[match]).replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                        }
                        
                        if let description = description, description.count > 0 {
                            return "<a href=\"\(urlString)\">\(description)</a>"
                        }
                        
                        return "<a href=\"\(urlString)\">\(originals[index])</a>"
                    }
                    
                    result = regex1.stringByReplacingMatches(in: result, templateForEach: resultTemplate)
                }
                
                if let regex = try? NSRegularExpression(pattern: "(?![\">])\(NSRegularExpression.escapedPattern(for: originals[index]))(?![\"<])", options: .caseInsensitive) {
                    result = regex.stringByReplacingMatches(in: result, templateForEach: { (match) -> String in
                        return "<a href=\"\(urlString)\">\(originals[index])</a>"
                    })
                }
                
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
            
            
            let safariVC = SFSafariViewController(url: url)
            parentViewController?.present(safariVC, animated: true, completion: nil)
            
            return false
        default:
            return true
        }
    }
}

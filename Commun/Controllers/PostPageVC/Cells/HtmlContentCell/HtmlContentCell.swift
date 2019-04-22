//
//  HtmlContentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 16/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import WebKit

class HtmlContentCell: UITableViewCell, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var needResize: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        webView.navigationDelegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupFromHtml(_ html: String) {
        webView.loadHTMLString("<html><body>\(html)</body></html>", baseURL: nil)
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if needResize {
            self.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                if complete != nil {
                    self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                        self.heightConstraint.constant = height as! CGFloat
                    })
                }
                
            })
        }
    }
}

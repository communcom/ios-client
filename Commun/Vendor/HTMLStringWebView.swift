//
//  HTMLWebView.swift
//  Commun
//
//  Created by Chung Tran on 24/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class HTMLStringWebView: UIWebView {
    var htmlString: String?
    override func loadHTMLString(_ string: String, baseURL: URL?) {
        guard htmlString != string else {return}
        htmlString = string
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
        let htmlEnd = "</BODY></HTML>"
        super.loadHTMLString(htmlStart + string + htmlEnd, baseURL: baseURL)
    }
}

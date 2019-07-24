//
//  UIWebView.swift
//  Commun
//
//  Created by Chung Tran on 14/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension UIWebView {
    var contentHeight: CGFloat {
        let string = stringByEvaluatingJavaScript(from: "document.documentElement.scrollHeight")
        guard let n = NumberFormatter().number(from: string ?? "0") else { return 0.0}
        return CGFloat(n)
    }
    
    var contentWidth: CGFloat {
        return self.scrollView.contentSize.width
    }
}

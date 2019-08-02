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
        let script = "document.documentElement.scrollHeight"
        if let returnedString = stringByEvaluatingJavaScript(from: script) {
            guard let n = NumberFormatter().number(from: returnedString) else { return self.scrollView.contentSize.height }
            return CGFloat(truncating: n)
        }
        
        return self.scrollView.contentSize.height
    }
    
    var contentWidth: CGFloat {
        return self.scrollView.contentSize.width
    }
}

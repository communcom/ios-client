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
        return self.scrollView.contentSize.height
    }
}

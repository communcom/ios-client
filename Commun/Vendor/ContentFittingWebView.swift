//
//  ContentFittingWebView.swift
//  Commun
//
//  Created by Chung Tran on 09/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class ContentFittingWebView: UIWebView {

    var contentSizeObservationToken: NSKeyValueObservation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        startObservingHeight()
    }
    
    override var intrinsicContentSize: CGSize {
        return scrollView.contentSize
    }
    
    func startObservingHeight() {
        contentSizeObservationToken?.invalidate()
        contentSizeObservationToken = scrollView.observe(\UIScrollView.contentSize, options: [.new], changeHandler: { (scrollView, change) in
            self.invalidateIntrinsicContentSize()
        })
    }


}

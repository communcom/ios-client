//
//  CMLabel.swift
//  Commun
//
//  Created by Chung Tran on 4/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMLabel: UILabel {
    var contentInset: UIEdgeInsets? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var s = super.intrinsicContentSize
        if let contentInset = contentInset {
            numberOfLines = 0       // don't forget!
            s.height = s.height + contentInset.top + contentInset.bottom
            s.width = s.width + contentInset.left + contentInset.right
        }
        return s
    }

    override func drawText(in rect: CGRect) {
        var r = rect
        if let contentInset = contentInset {
            r = rect.inset(by: contentInset)
        }
        super.drawText(in: r)
    }

    override func textRect(forBounds bounds: CGRect,
                           limitedToNumberOfLines n: Int) -> CGRect
    {
        var ctr = super.textRect(forBounds: bounds, limitedToNumberOfLines: n)
        
        if let contentInset = contentInset {
            let b = bounds
            let tr = b.inset(by: contentInset)
            ctr = super.textRect(forBounds: tr, limitedToNumberOfLines: 0)
        }
        
        return ctr
    }
}

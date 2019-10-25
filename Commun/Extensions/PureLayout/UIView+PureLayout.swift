//
//  UIView.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout

extension UIView {
    public convenience init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil
    ){
        self.init(forAutoLayout: ())
        if let width = width {
            autoSetDimension(.width, toSize: width)
        }
        if let height = height {
            autoSetDimension(.height, toSize: height)
        }
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        }
    }
    
    func autoPinTopAndLeadingToSuperView(inset: CGFloat = 16) {
        autoPinEdge(toSuperviewEdge: .leading, withInset: inset)
        autoPinEdge(toSuperviewEdge: .top, withInset: inset)
    }
    
    func autoPinTopAndTrailingToSuperView(inset: CGFloat = 16) {
        autoPinEdge(toSuperviewEdge: .top, withInset: inset)
        autoPinEdge(toSuperviewEdge: .trailing, withInset: inset)
    }
    
    func autoPinBottomAndLeadingToSuperView(inset: CGFloat = 16) {
        autoPinEdge(toSuperviewEdge: .bottom, withInset: inset)
        autoPinEdge(toSuperviewEdge: .leading, withInset: inset)
    }
    
    func autoPinBottomAndTrailingToSuperView(inset: CGFloat = 16) {
        autoPinEdge(toSuperviewEdge: .bottom, withInset: inset)
        autoPinEdge(toSuperviewEdge: .trailing, withInset: inset)
    }
}

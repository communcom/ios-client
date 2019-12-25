//
//  UIView.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import PureLayout

extension UIView {
    public convenience init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil
    ) {
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
    
    func autoPinTopAndLeadingToSuperView(inset: CGFloat = 0, xInset: CGFloat? = nil) {
        autoPinEdge(toSuperviewEdge: .leading, withInset: xInset ?? inset)
        autoPinEdge(toSuperviewEdge: .top, withInset: inset)
    }
    
    func autoPinTopAndTrailingToSuperView(inset: CGFloat = 16, xInset: CGFloat? = nil) {
        autoPinEdge(toSuperviewEdge: .top, withInset: inset)
        autoPinEdge(toSuperviewEdge: .trailing, withInset: xInset ?? inset)
    }
    
    func autoPinBottomAndLeadingToSuperView(inset: CGFloat = 16, xInset: CGFloat? = nil) {
        autoPinEdge(toSuperviewEdge: .bottom, withInset: inset)
        autoPinEdge(toSuperviewEdge: .leading, withInset: xInset ?? inset)
    }
    
    func autoPinBottomAndTrailingToSuperView(inset: CGFloat = 16, xInset: CGFloat? = nil) {
        autoPinEdge(toSuperviewEdge: .bottom, withInset: inset)
        autoPinEdge(toSuperviewEdge: .trailing, withInset: xInset ?? inset)
    }
    
    func autoPinTopAndLeadingToSuperViewSafeArea(inset: CGFloat = 0, xInset: CGFloat? = nil) {
        autoPinEdge(toSuperviewSafeArea: .leading, withInset: xInset ?? inset)
        autoPinEdge(toSuperviewSafeArea: .top, withInset: inset)
    }
    
    func autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: CGFloat = 0) {
        let keyboardViewV = KeyboardLayoutConstraint(item: superview!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: inset)
        keyboardViewV.observeKeyboardHeight()
        superview?.addConstraint(keyboardViewV)
    }
}

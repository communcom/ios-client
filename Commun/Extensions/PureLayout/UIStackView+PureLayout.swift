//
//  UIStackView+PureLayout.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import PureLayout

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, spacing: CGFloat? = nil, alignment: UIStackView.Alignment = .center) {
        self.init(forAutoLayout: ())
        self.axis = axis
        self.alignment = alignment
        distribution = .fillEqually
        if let spacing = spacing {
            self.spacing = spacing
        }
    }
}

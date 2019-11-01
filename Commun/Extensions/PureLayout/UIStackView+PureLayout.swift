//
//  UIStackView+PureLayout.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, spacing: CGFloat? = nil) {
        self.init(forAutoLayout: ())
        self.axis = axis
        alignment = .center
        distribution = .fillEqually
        if let spacing = spacing {
            self.spacing = spacing
        }
    }
}

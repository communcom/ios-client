//
//  UIStackView.swift
//  Commun
//
//  Created by Chung Tran on 12/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension UIStackView {
    func addBackground(color: UIColor, cornerRadius: CGFloat? = nil) {
        let subView = UIView(frame: bounds)
        if let radius = cornerRadius {
            subView.cornerRadius = radius
        }
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}

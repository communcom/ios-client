//
//  UILabel.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import PureLayout

extension UILabel {
    convenience init(
        text: String?,
        font: UIFont = .systemFont(ofSize: 15),
        numberOfLines: Int = 1,
        color: UIColor? = nil
    ) {
        self.init(forAutoLayout: ())
        self.text = text
        self.font = font
        self.numberOfLines = numberOfLines
        self.textColor = color
    }
    
    static func descriptionLabel(_ text: String? = nil, size: CGFloat = 12, numberOfLines: Int? = nil) -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.text = text
        label.font = .systemFont(ofSize: size, weight: .semibold)
        label.textColor = .appGrayColor
        if let numberOfLines = numberOfLines {
            label.numberOfLines = numberOfLines
        }
        return label
    }
    
    static func with(text: String? = nil, textSize: CGFloat = 15, weight: UIFont.Weight = .regular, textColor: UIColor = .appBlackColor, numberOfLines: Int? = nil, textAlignment: NSTextAlignment? = nil) -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.text = text
        label.font = .systemFont(ofSize: textSize, weight: weight)
        label.textColor = textColor
        if let numberOfLines = numberOfLines {
            label.numberOfLines = numberOfLines
        }
        if let textAlignment = textAlignment {
            label.textAlignment = textAlignment
        }
        return label
    }
}

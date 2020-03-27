//
//  UILabel+Extensions.swift
//  Golos
//
//  Created by msm72 on 09.06.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//

import UIKit

extension UILabel {
    public func tune(withText text: String, textColor: UIColor?, font: UIFont?, alignment: NSTextAlignment, isMultiLines: Bool) {
        self.text = text.localized()
        self.font = font
        self.textColor = textColor
        self.numberOfLines = isMultiLines ? 0 : 1
        self.textAlignment = alignment
    }
}

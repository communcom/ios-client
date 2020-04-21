//
//  UITextField.swift
//  Commun
//
//  Created by Chung Tran on 1/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UITextField {
    public func tune(withPlaceholder placeholder: String, textColor: UIColor?, font: UIFont?, alignment: NSTextAlignment) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = alignment
        self.attributedPlaceholder = NSAttributedString(string: placeholder.localized().uppercaseFirst,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.appGrayColor])
    }

    static func decimalPad(
        backgroundColor: UIColor = .clear,
        placeholder: String = "0",
        placeholderTextColor: UIColor = .appGrayColor,
        borderStyle: UITextField.BorderStyle = .none,
        font: UIFont = .systemFont(ofSize: 17, weight: .semibold)
    ) -> UITextField {
        let textField = UITextField(backgroundColor: .clear)
       textField.placeholder = placeholder
       textField.borderStyle = borderStyle
       textField.font = font
       textField.setPlaceHolderTextColor(placeholderTextColor)
       textField.keyboardType = .decimalPad
       return textField
    }
}

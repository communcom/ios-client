//
//  UITextField+PureLayout.swift
//  Commun
//
//  Created by Chung Tran on 3/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UITextField {
    static func signUpTextField(
        width: CGFloat? = nil,
        font: UIFont = .systemFont(ofSize: 17),
        keyboardType: UIKeyboardType = .alphabet,
        placeholder: String? = nil,
        isSecureTextEntry: Bool = false,
        leftView: UIView = UIView(width: 16, height: 56),
        rightView: UIView = UIView(width: 16, height: 56)
    ) -> UITextField {
        let tf = UITextField(width: width, height: 56, backgroundColor: .f3f5fa, cornerRadius: 12)
        tf.font = font
        tf.keyboardType = keyboardType
        if let placeholder = placeholder {
            tf.placeholder = placeholder.localized().uppercaseFirst
        }
        
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
        tf.isSecureTextEntry = isSecureTextEntry
        
        tf.leftView = leftView
        tf.leftViewMode = .always
        
        tf.rightView = rightView
        tf.rightViewMode = .always
        return tf
    }
}

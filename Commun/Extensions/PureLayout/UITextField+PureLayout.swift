//
//  UITextField+PureLayout.swift
//  Commun
//
//  Created by Chung Tran on 3/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UITextField {
    convenience init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        backgroundColor: UIColor = .appLightGrayColor,
        cornerRadius: CGFloat? = nil,
        font: UIFont? = nil,
        keyboardType: UIKeyboardType = .alphabet,
        placeholder: String?,
        autocorrectionType: UITextAutocorrectionType? = nil,
        autocapitalizationType: UITextAutocapitalizationType? = nil,
        spellCheckingType: UITextSpellCheckingType? = nil,
        textContentType: UITextContentType? = nil,
        isSecureTextEntry: Bool = false,
        leftView: UIView = UIView(width: 16),
        leftViewMode: UITextField.ViewMode = .always,
        rightView: UIView = UIView(width: 16),
        rightViewMode: UITextField.ViewMode = .always,
        showClearButton: Bool = false
    ) {
        self.init(width: width, height: height, backgroundColor: backgroundColor, cornerRadius: cornerRadius)
        if let font = font {
            self.font = font
        }
        self.keyboardType = keyboardType
        self.placeholder = placeholder
        if let autocorrectionType = autocorrectionType {
            self.autocorrectionType = autocorrectionType
        }
        if let autocapitalizationType = autocapitalizationType {
            self.autocapitalizationType = autocapitalizationType
        }
        if let spellCheckingType = spellCheckingType {
            self.spellCheckingType = spellCheckingType
        }
        
        if let textContentType = textContentType {
            self.textContentType = textContentType
        }
        
        self.isSecureTextEntry = isSecureTextEntry
        
        leftView.autoSetDimension(.height, toSize: height ?? 16)
        self.leftView = leftView
        self.leftViewMode = leftViewMode
        
        if !showClearButton {
            rightView.autoSetDimension(.height, toSize: height ?? 16)
            self.rightView = rightView
            self.rightViewMode = rightViewMode
        } else {
            self.clearButtonMode = .whileEditing
        }
        
    }
    
    static func signUpTextField(
        width: CGFloat? = nil,
        font: UIFont = .systemFont(ofSize: 17),
        keyboardType: UIKeyboardType = .alphabet,
        placeholder: String? = nil,
        isSecureTextEntry: Bool = false,
        leftView: UIView = UIView(width: 16, height: 56),
        rightView: UIView = UIView(width: 16, height: 56)
    ) -> UITextField {
        let tf = UITextField(
            width: width,
            height: 56,
            cornerRadius: 12,
            font: font,
            keyboardType: keyboardType,
            placeholder: placeholder,
            autocorrectionType: .no,
            autocapitalizationType: UITextAutocapitalizationType.none,
            spellCheckingType: .no,
            isSecureTextEntry: isSecureTextEntry,
            leftView: leftView,
            rightView: rightView)
        return tf
    }
}

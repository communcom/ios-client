//
//  CreatePasswordTextField.swift
//  Commun
//
//  Created by Chung Tran on 4/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreatePasswordTextField: UITextField {
    convenience init(
        width: CGFloat? = nil,
        font: UIFont = .systemFont(ofSize: 17),
        keyboardType: UIKeyboardType = .alphabet,
        placeholder: String? = nil,
        isSecureTextEntry: Bool = false,
        leftView: UIView = UIView(width: 16, height: 56),
        rightView: UIView = UIView(width: 16, height: 56)
    ) {
        self.init(
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
            rightView: rightView
        )
    }
    
    override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
        }
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {

        let success = super.becomeFirstResponder()
        if isSecureTextEntry, let text = self.text {
            self.text?.removeAll()
            insertText(text)
        }
        return success
    }
}

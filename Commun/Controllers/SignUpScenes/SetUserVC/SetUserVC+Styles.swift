//
//  SetUserVC+Styles.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension SetUserVC {
    func tuneCreateUserNameLabel() {
        self.creatUsernameLabel.tune(
            withText:           "create your username".localized().uppercaseFirst,
            hexColors:           blackWhiteColorPickers,
            font:               UIFont(
                name:           "SFProText-Regular",
                size:           CGFloat.adaptive(width: 17.0)
            ),
            alignment:         .left,
            isMultiLines:      false)
    }
    
    func tuneUserNameTextField() {
        self.userNameTextField.tune(withPlaceholder:    "username placeholder".localized().uppercaseFirst,
                                    textColors:         blackWhiteColorPickers,
                                    font:               UIFont.init(name: "SFProText-Regular", size: CGFloat.adaptive(width: 17.0)),
                                    alignment:          .left)
        
        self.userNameTextField.inset = CGFloat.adaptive(width: 16.0)
        self.userNameTextField.layer.cornerRadius = CGFloat.adaptive(height: 12.0)
        self.userNameTextField.clipsToBounds = true
        self.userNameTextField.keyboardType = .alphabet
    }    
}

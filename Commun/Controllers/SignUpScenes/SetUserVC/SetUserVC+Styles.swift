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
            withText:          "create your username".localized().uppercaseFirst,
            hexColors:         blackWhiteColorPickers,
            font:              UIFont(
                name: "SFProText-Regular",
                size: 17.0 * Config.widthRatio
            ),
            alignment:         .left,
            isMultiLines:      false)
    }
    
    func tuneUserNameTextField() {
        self.userNameTextField.tune(withPlaceholder:    "username placeholder".localized().uppercaseFirst,
                                    textColors:         blackWhiteColorPickers,
                                    font:               UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                    alignment:          .left)
        
        self.userNameTextField.inset = 16.0 * Config.widthRatio
        self.userNameTextField.layer.cornerRadius = 12.0 * Config.heightRatio
        self.userNameTextField.clipsToBounds = true
        self.userNameTextField.keyboardType = .alphabet
    }
    
    func tuneTraitLabels() {
        for i in 0..<traitLabels.count {
            traitLabels[i].text = traitLabels[i].text?.localized().uppercaseFirst
        }
    }
}

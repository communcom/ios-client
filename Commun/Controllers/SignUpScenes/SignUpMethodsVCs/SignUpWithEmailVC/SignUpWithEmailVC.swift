//
//  SignUpWithEmailVC.swift
//  Commun
//
//  Created by Chung Tran on 3/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SignUpWithEmailVC: BaseSignUpMethodVC {
    // MARK: - Subviews
    lazy var textField = UITextField.signUpTextField(width: 290, placeholder: "your email address")
    
    // MARK: - Methods
    override func setUpInputViews() {
        scrollView.contentView.addSubview(textField)
        textField.autoPinEdge(toSuperviewEdge: .top, withInset: UIScreen.main.isSmall ? 16 : 47)
        textField.autoAlignAxis(toSuperviewAxis: .vertical)
    }
    
    override func pinBottomOfInputViews() {
        termOfUseLabel.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 30)
    }
}

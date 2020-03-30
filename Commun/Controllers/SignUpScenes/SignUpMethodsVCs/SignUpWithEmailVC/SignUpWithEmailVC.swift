//
//  SignUpWithEmailVC.swift
//  Commun
//
//  Created by Chung Tran on 3/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SignUpWithEmailVC: BaseSignUpMethodVC {
    // MARK: - Properties
    let viewModel = SignUpWithEmailViewModel()
    
    // MARK: - Subviews
    lazy var textField = UITextField.signUpTextField(width: 290, placeholder: "your email address")
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        // TODO: - Add analystic manager
    }
    
    override func setUpInputViews() {
        scrollView.contentView.addSubview(textField)
        textField.autoPinEdge(toSuperviewEdge: .top, withInset: UIScreen.main.isSmall ? 16 : 47)
        textField.autoAlignAxis(toSuperviewAxis: .vertical)
        
        scrollView.contentView.addSubview(errorLabel)
        errorLabel.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 10)
        errorLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 32)
        errorLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 32)
    }
    
    override func pinBottomOfInputViews() {
        termOfUseLabel.autoPinEdge(.top, to: .bottom, of: errorLabel, withOffset: 30)
    }
    
    override func bind() {
        super.bind()
        
        let emailValidationObservable = textField.rx.text.orEmpty
            .map {self.viewModel.isEmailValid($0)}
        
        emailValidationObservable
            .filter {_ in self.textField.text!.isEmpty == false}
            .map {$0 ? nil : "invalid email address".localized().uppercaseFirst}
            .bind(to: errorLabel.rx.text)
            .disposed(by: disposeBag)
        
        emailValidationObservable
            .bind(to: nextButton.rx.isDisabled)
            .disposed(by: disposeBag)
    }
    
    override func nextButtonDidTouch() {
        // TODO: - Analystic manager
//        AnalyticsManger.shared.PhoneNumberEntered()

        self.view.endEditing(true)
        self.showIndetermineHudWithMessage("signing you up".localized().uppercaseFirst + "...")
        
        
    }
}

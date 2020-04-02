//
//  CreatePasswordVC.swift
//  Commun
//
//  Created by Chung Tran on 3/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreatePasswordVC: BaseSignUpVC, SignUpRouter {
    // MARK: - Properties
    let viewModel = CreatePasswordViewModel()
    var masterPasswordButton: UIButton?
    override var autoPinNextButtonToBottom: Bool {true}
    
    // MARK: - Subviews
    lazy var textField: UITextField = {
        let rightView = UIView(width: 44, height: 56)
        rightView.addSubview(showPasswordButton)
        showPasswordButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        showPasswordButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let tf = UITextField.signUpTextField(width: 290, placeholder: "password".localized().uppercaseFirst, isSecureTextEntry: true, rightView: rightView)
        return tf
    }()
    
    lazy var showPasswordButton: UIButton = {
        let button = UIButton(width: 44, height: 56, contentInsets: UIEdgeInsets(top: 21, left: 12, bottom: 21, right: 12))
        button.setImage(UIImage(named: "show-password"), for: .normal)
        button.addTarget(self, action: #selector(showPasswordDidTouch), for: .touchUpInside)
        return button
    }()
    
    lazy var constraintsStackView = UIStackView(axis: .horizontal, spacing: 16)

    lazy var unsupportSymbolError = UILabel.with(textSize: 12, weight: .medium, textColor: .appRedColor, numberOfLines: 2, textAlignment: .center)

    // MARK: - Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        textField.resignFirstResponder()
    }
    
    override func setUp() {
        super.setUp()
        titleLabel.text = String(format: "%@ %@", "create".localized().uppercaseFirst, "password".localized().uppercaseFirst)
        
        if UIScreen.main.isSmall {
            titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        }
        
        AnalyticsManger.shared.openEnterPassword()
        // text field
        scrollView.contentView.addSubview(textField)
        textField.autoPinEdge(toSuperviewEdge: .top, withInset: UIScreen.main.isSmall ? 36 : 50)
        textField.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // traits view
        scrollView.contentView.addSubview(constraintsStackView)
        constraintsStackView.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 16)
        constraintsStackView.autoAlignAxis(toSuperviewAxis: .vertical)
        constraintsStackView.autoPinEdge(toSuperviewEdge: .bottom)
        
        // generateMasterPasswordButton
        setUpGenerateMasterPasswordButton()

        view.addSubview(unsupportSymbolError)
        unsupportSymbolError.autoPinEdge(.bottom, to: .top, of: nextButton, withOffset: -9)
        unsupportSymbolError.autoAlignAxis(toSuperviewAxis: .vertical)
        unsupportSymbolError.text = "only Latin characters, digits and".localized().uppercaseFirst
        unsupportSymbolError.isHidden = true
    }
    
    func setUpGenerateMasterPasswordButton() {
        let button = UIButton(label: "i want to use Master Password".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .semibold), textColor: .appMainColor)
        view.addSubview(button)
        button.autoAlignAxis(toSuperviewAxis: .vertical)
        button.autoPinEdge(.bottom, to: .top, of: nextButton, withOffset: -16)
        
        button.addTarget(self, action: #selector(generateMasterPasswordButtonDidTouch), for: .touchUpInside)
        masterPasswordButton = button
    }
    
    override func bind() {
        super.bind()
        // text field
        textField.rx.text.orEmpty
            .map {self.viewModel.validate(password: $0)}
            .bind(to: nextButton.rx.isDisabled)
            .disposed(by: disposeBag)

        textField.rx.text.subscribe { (event) in
            let text = event.element ?? ""
            self.unsupportSymbolError.isHidden = self.viewModel.isValidSymbols(string: text)
            self.masterPasswordButton?.isHidden = text!.count > 0
        }.disposed(by: disposeBag)
        
        textField.delegate = self
        
        // viewModel
        viewModel.isShowingPassword
            .subscribe(onNext: { (isShowingPassword) in
                self.textField.isSecureTextEntry = !isShowingPassword
                self.showPasswordButton.setImage(UIImage(named: (isShowingPassword ? "hide" : "show") + "-password"), for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel.constraints
            .subscribe(onNext: { constraints in
                if self.constraintsStackView.arrangedSubviews.count == 0 {
                    let constraintViews = constraints.map { constraint -> PasswordConstraintView in
                        let view = PasswordConstraintView()
                        view.setUp(with: constraint)
                        return view
                    }
                    self.constraintsStackView.addArrangedSubviews(constraintViews)
                } else {
                    let constraintViews = self.constraintsStackView.arrangedSubviews as! [PasswordConstraintView]
                    for view in constraintViews {
                        guard let changedConstraint = constraints.first(where: {$0.title == view.constraint?.title}) else {return}
                        view.setUp(with: changedConstraint)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    override func backButtonDidTouch() {
        resetSignUpProcess()
    }
    
    @objc func showPasswordDidTouch() {
        viewModel.isShowingPassword.accept(!viewModel.isShowingPassword.value)
    }
    
    @objc func generateMasterPasswordButtonDidTouch() {
        showAttention(
            subtitle: "you want to select the advanced mode".localized().uppercaseFirst,
            descriptionText: "after confirmation, we'll generate for".localized().uppercaseFirst,
            ignoreButtonLabel: "continue with Master Password".localized().uppercaseFirst,
            ignoreAction: {
                AnalyticsManger.shared.useMasterPassword()
                let vc = GenerateMasterPasswordVC()
                self.show(vc, sender: nil)
            }
        )
    }
    
    @objc override func nextButtonDidTouch() {
        if (textField.text ?? "").count > AuthManager.maxPasswordLength {
            hintView?.display(inPosition: nextButton.frame.origin, withType: .error("password must contain no more than".localized().uppercaseFirst))
            return
        }
        
        if let failureConstraint = viewModel.constraints.value.first(where: {!$0.isSastified}) {
            var message = "something went wrong".localized().uppercaseFirst
            switch failureConstraint.title {
            case CreatePasswordViewModel.lowercaseTitle:
                message = "password must contain at least one lowercase".localized().uppercaseFirst
            case CreatePasswordViewModel.uppercaseTitle:
                message = "password must contain at least one uppercase".localized().uppercaseFirst
            case CreatePasswordViewModel.numberTitle:
                message = "password must contain at least one digit".localized().uppercaseFirst
            case CreatePasswordViewModel.minLengthTitle:
                message = "password must contain at least 8 characters".localized().uppercaseFirst
            default:
                break
            }
            hintView?.display(inPosition: nextButton.frame.origin, withType: .error(message))
            return
        }
        
        validationDidComplete()
    }
    
    func validationDidComplete() {
        guard let currentPassword = textField.text else {return}
        view.endEditing(true)

        // fix animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let confirmVC = ConfirmPasswordVC(currentPassword: currentPassword)
            self.show(confirmVC, sender: nil)
        }
    }
}

extension CreatePasswordVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        string.rangeOfCharacter(from: .whitespaces) == nil
    }
}

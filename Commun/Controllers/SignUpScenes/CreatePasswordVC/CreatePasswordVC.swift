//
//  CreatePasswordVC.swift
//  Commun
//
//  Created by Chung Tran on 3/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreatePasswordVC: SignUpBaseVC, SignUpRouter {
    // MARK: - Nested type
    class ConstraintView: MyView {
        var constraint: CreatePasswordViewModel.Constraint?
        let activeColor = UIColor.appMainColor
        let inactiveColor = UIColor.a5a7bd
        lazy var symbol = UILabel.with(textSize: 22, weight: .medium, textColor: inactiveColor, textAlignment: .center)
        lazy var title = UILabel.with(textSize: 12, textColor: inactiveColor, textAlignment: .center)
        
        override func commonInit() {
            super.commonInit()
            addSubview(symbol)
            symbol.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            addSubview(title)
            title.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            title.autoPinEdge(.top, to: .bottom, of: symbol, withOffset: 0)
        }
        
        var isActive = false {
            didSet {
                symbol.textColor = isActive ? activeColor : inactiveColor
                title.textColor = isActive ? activeColor : inactiveColor
            }
        }
        
        func setUp(with constraint: CreatePasswordViewModel.Constraint) {
            self.constraint = constraint
            symbol.text = constraint.symbol
            title.text = constraint.title.localized().uppercaseFirst
            isActive = constraint.isSastified
        }
    }
    // MARK: - Properties
    let viewModel = CreatePasswordViewModel()
    var masterPasswordButton: UIButton?
    // MARK: - Subviews
    lazy var textField: UITextField = {
        let tf = UITextField(width: 290, height: 56, backgroundColor: .f3f5fa, cornerRadius: 12)
        tf.font = .systemFont(ofSize: 17 * Config.heightRatio)
        tf.keyboardType = .alphabet
        tf.placeholder = "password".localized().uppercaseFirst
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
        tf.isSecureTextEntry = true
        
        let leftView = UIView(width: 16, height: 56)
        tf.leftView = leftView
        tf.leftViewMode = .always
        
        let rightView = UIView(width: 44, height: 56)
        rightView.addSubview(showPasswordButton)
        showPasswordButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        showPasswordButton.autoAlignAxis(toSuperviewAxis: .vertical)
        tf.rightView = rightView
        tf.rightViewMode = .always
        return tf
    }()
    
    lazy var showPasswordButton: UIButton = {
        let button = UIButton(width: 44, height: 56, contentInsets: UIEdgeInsets(top: 21, left: 12, bottom: 21, right: 12))
        button.setImage(UIImage(named: "show-password"), for: .normal)
        button.addTarget(self, action: #selector(showPasswordDidTouch), for: .touchUpInside)
        return button
    }()
    
    lazy var constraintsStackView = UIStackView(axis: .horizontal, spacing: 16)
    
    lazy var nextButton: CommunButton = {
        let button = CommunButton.default(height: 56, label: "next".localized().uppercaseFirst, cornerRadius: 8, isHuggingContent: false, isDisableGrayColor: true)
        button.autoSetDimension(.width, toSize: 290)
        return button
    }()

    lazy var unsupportSymbolError = UILabel.with(textSize: 12, weight: .medium, textColor: .appRedColor, numberOfLines: 2, textAlignment: .center)

    // MARK: - Methods
    override func setUp() {
        super.setUp()
        titleLabel.text = "create Password".localized().uppercaseFirst
        AnalyticsManger.shared.openEnterPassword()
        // text field
        scrollView.contentView.addSubview(textField)
        switch UIDevice.current.screenType {
        case .iPhones_5_5s_5c_SE:
            textField.autoPinEdge(toSuperviewEdge: .top, withInset: 36)
        default:
            textField.autoPinEdge(toSuperviewEdge: .top, withInset: 50)
        }
        textField.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // traits view
        scrollView.contentView.addSubview(constraintsStackView)
        constraintsStackView.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 16)
        constraintsStackView.autoAlignAxis(toSuperviewAxis: .vertical)
        constraintsStackView.autoPinEdge(toSuperviewEdge: .bottom)
        
        // button
        view.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(nextButtonDidTouch), for: .touchUpInside)
        nextButton.autoAlignAxis(toSuperviewAxis: .vertical)
        let constant: CGFloat
        switch UIDevice.current.screenType {
        case .iPhones_5_5s_5c_SE:
            constant = 16
        default:
            constant = 40
        }
        
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: nextButton, attribute: .bottom, multiplier: 1.0, constant: constant)
        keyboardViewV.observeKeyboardHeight()
        view.addConstraint(keyboardViewV)
        
        // generateMasterPasswordButton
        setUpGenerateMasterPasswordButton()
        
        // hide keyboard
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        view.addSubview(unsupportSymbolError)
        unsupportSymbolError.autoPinEdge(.bottom, to: .top, of: nextButton, withOffset: -9)
        unsupportSymbolError.autoAlignAxis(toSuperviewAxis: .vertical)
        unsupportSymbolError.text = "only Latin characters, digits and special symbols\nare allowed".localized().uppercaseFirst
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
                    let constraintViews = constraints.map { constraint -> ConstraintView in
                        let view = ConstraintView()
                        view.setUp(with: constraint)
                        return view
                    }
                    self.constraintsStackView.addArrangedSubviews(constraintViews)
                } else {
                    let constraintViews = self.constraintsStackView.arrangedSubviews as! [ConstraintView]
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
            subtitle: "you want to select the advanced mode and continue with the Master Password".localized().uppercaseFirst,
            descriptionText: "after confirmation, we'll generate for you a 52-character crypto password.\nWe suggest you copy this password or download a PDF file with it.\nWe do not keep Master Passwords and have no opportunity to restore them.\n\nWe strongly recommend you to save your password and make its copy.".localized().uppercaseFirst,
            ignoreButtonLabel: "continue with Master Password".localized().uppercaseFirst,
            ignoreAction: {
                AnalyticsManger.shared.useMasterPassword()
                let vc = GenerateMasterPasswordVC()
                self.show(vc, sender: nil)
            }
        )
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func nextButtonDidTouch() {
        if (textField.text ?? "").count > AuthManager.maxPasswordLength {
            hintView?.display(inPosition: nextButton.frame.origin, withType: .error("password must contain no more than 52 characters".localized().uppercaseFirst))
            return
        }
        
        if let failureConstraint = viewModel.constraints.value.first(where: {!$0.isSastified}) {
            var message = "something went wrong".localized().uppercaseFirst
            switch failureConstraint.title {
            case CreatePasswordViewModel.lowercaseTitle:
                message = "password must contain at least one lowercase character".localized().uppercaseFirst
            case CreatePasswordViewModel.uppercaseTitle:
                message = "password must contain at least one uppercase character".localized().uppercaseFirst
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

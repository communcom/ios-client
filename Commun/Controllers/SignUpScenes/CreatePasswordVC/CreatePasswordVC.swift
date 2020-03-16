//
//  CreatePasswordVC.swift
//  Commun
//
//  Created by Chung Tran on 3/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CreatePasswordVC: SignUpBaseVC {
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
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        titleLabel.text = "create Password".localized().uppercaseFirst
        
        // text field
        scrollView.contentView.addSubview(textField)
        switch UIDevice.current.screenType {
        case .iPhones_5_5s_5c_SE:
            textField.autoPinEdge(toSuperviewEdge: .top, withInset: 36)
        default:
            textField.autoPinEdge(toSuperviewEdge: .top, withInset: 83)
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
        
        // hide keyboard
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func bind() {
        super.bind()
        // text field
        textField.rx.text.orEmpty
            .map {self.viewModel.validate(password: $0)}
            .bind(to: nextButton.rx.isDisabled)
            .disposed(by: disposeBag)
        
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
    @objc func showPasswordDidTouch() {
        viewModel.isShowingPassword.accept(!viewModel.isShowingPassword.value)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func nextButtonDidTouch() {
        if let failureConstraint = viewModel.constraints.value.first(where: {!$0.isSastified}) {
            var message = "something went wrong".localized().uppercaseFirst
            switch failureConstraint.title {
            case "lowercase":
                message = "password must contain at least one lowercase character".localized().uppercaseFirst
            case "uppercase":
                message = "password must contain at least one uppercase character".localized().uppercaseFirst
            case "symbol":
                message = "password must contain at least one special character".localized().uppercaseFirst
            case "min length":
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
        let confirmVC = ConfirmPasswordVC(currentPassword: currentPassword)
        show(confirmVC, sender: nil)
    }
}

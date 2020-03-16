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
        let activeColor = UIColor.appMainColor
        let inactiveColor = UIColor.a5a7bd
        lazy var symbol = UILabel.with(textSize: 22, weight: .medium, textColor: inactiveColor, textAlignment: .center)
        lazy var title = UILabel.with(textSize: 12, textColor: inactiveColor, textAlignment: .center)
        
        var isActive = false {
            didSet {
                symbol.textColor = isActive ? activeColor : inactiveColor
                title.textColor = isActive ? activeColor : inactiveColor
            }
        }
        
        func setUp(with trait: Constraint) {
            symbol.text = trait.symbol
            title.text = trait.title.localized().uppercaseFirst
            isActive = trait.isActive
        }
    }
    
    struct Constraint {
        var symbol: String
        var title: String
        var isActive = false
    }
    // MARK: - Properties
    let viewModel = CreatePasswordViewModel()
    let constraints: [Constraint] = [
        Constraint(symbol: "a", title: "lowercase"),
        Constraint(symbol: "A", title: "uppercase"),
        Constraint(symbol: "$", title: "symbol"),
        Constraint(symbol: "8+", title: "min length")
    ]
    
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
    
    lazy var nextButton = CommunButton(width: 290, height: 56, label: "next".localized().uppercaseFirst, cornerRadius: 8, completionDisable: {
        
    })
    
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
        let stackView = UIStackView(axis: .horizontal, spacing: 16)
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 16)
        stackView.autoAlignAxis(toSuperviewAxis: .vertical)
        stackView.autoPinEdge(toSuperviewEdge: .bottom)
        
        let constraintViews = constraints.map { constraint -> ConstraintView in
            let view = ConstraintView()
            view.setUp(with: constraint)
            return view
        }
        stackView.addArrangedSubviews(constraintViews)
        
        // button
        view.addSubview(nextButton)
        let constant: CGFloat
        switch UIDevice.current.screenType {
        case .iPhones_5_5s_5c_SE:
            constant = 16
        default:
            constant = 40
        }
        
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: nextButton, attribute: .bottom, multiplier: 1.0, constant: constant)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
    }
    
    override func bind() {
        super.bind()
        viewModel.isShowingPassword
            .subscribe(onNext: { (isShowingPassword) in
                self.textField.isSecureTextEntry = !isShowingPassword
                self.showPasswordButton.setImage(UIImage(named:(isShowingPassword ? "hide": "show") + "-password"), for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc func showPasswordDidTouch() {
        viewModel.isShowingPassword.accept(!viewModel.isShowingPassword.value)
    }
}

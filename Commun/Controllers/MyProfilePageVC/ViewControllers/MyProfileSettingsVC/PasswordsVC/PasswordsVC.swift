//
//  PasswordsVC.swift
//  Commun
//
//  Created by Chung Tran on 6/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class PasswordsVC: BaseViewController {
    // MARK: - Properties
    var authenticated = false
    let showPasswordSubject = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var passwordField = secretFieldWithTitle("password".localized().uppercaseFirst)
    lazy var ownerField = secretFieldWithTitle("owner".localized().uppercaseFirst)
    lazy var activeField = secretFieldWithTitle("active".localized().uppercaseFirst)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        title = "passwords".localized().uppercaseFirst
        
        // backButton
        setLeftNavBarButtonForGoingBack()

        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        scrollView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard()
        
        // stackView
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))
        
        // password
        stackView.addArrangedSubviews([
            passwordField,
            ownerField,
            activeField
        ])
    }
    
    override func bind() {
        super.bind()
        showPasswordSubject
            .subscribe(onNext: { (show) in
                if show {
                    (self.passwordField.viewWithTag(1) as! UILabel).text = "test"
                } else {
                    (self.passwordField.viewWithTag(1) as! UILabel).text = "••••••••••••••••••••••••••••"
                    (self.ownerField.viewWithTag(1) as! UILabel).text = "••••••••••••••••••••••••••••"
                    (self.activeField.viewWithTag(1) as! UILabel).text = "••••••••••••••••••••••••••••"
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func secretFieldWithTitle(_ title: String) -> UIView {
        let view = UIView(backgroundColor: .white, cornerRadius: 10)
        let stackView = UIStackView(axis: .vertical, spacing: 8, alignment: .fill, distribution: .fill)
        view.addSubview(stackView)
        
        let titleLabel = UILabel.with(text: title, textSize: 12, weight: .medium, textColor: .appGrayColor)
        
        let passwordField = UIView(backgroundColor: .clear)
        
        let passwordLabel = UILabel.with(textSize: 17, weight: .medium)
        passwordLabel.tag = 1
        let showPasswordButton = UIButton(width: 24, height: 16)
        showPasswordButton.setImage(UIImage(named: "show-password"), for: .normal)
        showPasswordButton.addTarget(self, action: #selector(toggleShowHidePassword), for: .touchUpInside)
        
        passwordField.addSubview(passwordLabel)
        passwordLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        passwordField.addSubview(showPasswordButton)
        showPasswordButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)
        passwordLabel.autoPinEdge(.trailing, to: .leading, of: showPasswordButton, withOffset: -8)
        
        stackView.addArrangedSubviews([titleLabel, passwordField])
        
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        
        return view
    }
    
    @objc private func toggleShowHidePassword() {
        if showPasswordSubject.value {
            showPasswordSubject.accept(false)
            return
        }
        
        if authenticated {
            showPasswordSubject.accept(true)
            return
        }
        
        // TODO: - Authentication
        showPasswordSubject.accept(true)
    }
}

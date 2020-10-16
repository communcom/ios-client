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
    // MARK: - Nested types
    class FieldTapGestureRecognizer: UITapGestureRecognizer {
        weak var label: UILabel?
    }
    
    // MARK: - Properties
    var authenticated = false
    let showPasswordSubject = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    lazy var passwordField = secretFieldWithTitle("password".localized().uppercaseFirst)
    lazy var changePasswordButton: UIView = {
        let hStack = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        let icon = UIImageView(width: 30, height: 30, cornerRadius: 15, imageNamed: "change-password-icon")
        let label = UILabel.with(text: "change".localized().uppercaseFirst, textSize: 15, weight: .semibold)
        hStack.addArrangedSubviews([icon, label])
        
        let view = UIView(height: 50, backgroundColor: .appWhiteColor, cornerRadius: 10)
        view.addSubview(hStack)
        hStack.autoCenterInSuperview()
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePasswordButtonDidTouch)))
        return view
    }()
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
            changePasswordButton,
            ownerField,
            activeField
        ])
        
        stackView.setCustomSpacing(30, after: changePasswordButton)
        stackView.setCustomSpacing(10, after: ownerField)
    }
    
    override func bind() {
        super.bind()
        showPasswordSubject
            .subscribe(onNext: { (show) in
                self.showPassword(show)
            })
            .disposed(by: disposeBag)
    }
    
    func showPassword(_ show: Bool) {
        if show {
            (self.passwordField.viewWithTag(1) as! UILabel).text = Config.currentUser?.masterKey
            (self.ownerField.viewWithTag(1) as! UILabel).text = Config.currentUser?.ownerKeys?.privateKey
            (self.activeField.viewWithTag(1) as! UILabel).text = Config.currentUser?.activeKeys?.privateKey
        } else {
            (self.passwordField.viewWithTag(1) as! UILabel).text = "••••••••••••••••••••••••••••"
            (self.ownerField.viewWithTag(1) as! UILabel).text = "••••••••••••••••••••••••••••"
            (self.activeField.viewWithTag(1) as! UILabel).text = "••••••••••••••••••••••••••••"
        }
    }
    
    private func secretFieldWithTitle(_ title: String) -> UIView {
        let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
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
        
        view.isUserInteractionEnabled = true
        let tapGesture = FieldTapGestureRecognizer()
        tapGesture.label = passwordLabel
        tapGesture.addTarget(self, action: #selector(fieldDidTouch(_:)))
        view.addGestureRecognizer(tapGesture)
        
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
        
        let confirmPasscodeVC = ConfirmPasscodeVC()
        present(confirmPasscodeVC, animated: true, completion: nil)
        
        confirmPasscodeVC.completion = {
            self.authenticated = true
            self.showPasswordSubject.accept(true)
        }
    }
    
    @objc private func fieldDidTouch(_ gesture: FieldTapGestureRecognizer) {
        guard showPasswordSubject.value,
            let textToCopy = gesture.label?.text
        else {return}
        UIPasteboard.general.string = textToCopy
        showDone("copied to clipboard".localized().uppercaseFirst)
    }
    
    @objc private func changePasswordButtonDidTouch() {
        let confirmPasscodeVC = ConfirmPasscodeVC()
        present(confirmPasscodeVC, animated: true, completion: nil)
        
        confirmPasscodeVC.completion = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let vc = ChangePasswordVC()
                vc.completion = {
                    self.showPassword(false)
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}

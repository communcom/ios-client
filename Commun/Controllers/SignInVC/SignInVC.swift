//
//  SignInVC.swift
//  Commun
//
//  Created by Chung Tran on 12/9/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

typealias LoginCredential = (login: String, key: String)

class SignInVC: BaseViewController {
    // MARK: - Properties
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.hidden}
    let viewModel = SignInViewModel()
    
    // MARK: - Subviews
    lazy var backButton = UIButton.back(contentInsets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 15))
    lazy var titleLabel = UILabel.with(text: "welcome".localized().uppercaseFirst, textSize: 34, weight: .bold)
    
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    
    lazy var loginTextField = UITextField(width: 290, height: 56, cornerRadius: 12, placeholder: "login placeholder".localized().uppercaseFirst, autocorrectionType: .no, autocapitalizationType: UITextAutocapitalizationType.none, spellCheckingType: .no, textContentType: .username)
    
    lazy var passwordTextField = UITextField(width: 290, height: 56, cornerRadius: 12, placeholder: "key placeholder".localized().uppercaseFirst, autocorrectionType: .no, autocapitalizationType: UITextAutocapitalizationType.none, spellCheckingType: .no, textContentType: .password, isSecureTextEntry: true)
    
    lazy var pasteFromClipboardButton = UIButton(labelFont: .systemFont(ofSize: 15), textColor: .appMainColor)
    
    lazy var signInButton = CommunButton.default(height: 56, label: "sign in".localized().uppercaseFirst, cornerRadius: 8, isDisableGrayColor: true)
    lazy var signUpButton = UIButton(label: "don't have an account?".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), textColor: .appMainColor)
    
    lazy var scanQrCodeButton = UIButton.roundedCorner(8, size: 56, backgroundColor: .appMainColor, tintColor: .white, imageName: "scan-qr-code")
    
    // MARK: - Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginTextField.becomeFirstResponder()
    }
    
    override func setUp() {
        super.setUp()
        
        // title
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.autoPinTopAndLeadingToSuperViewSafeArea(inset: 10, xInset: 0)
        
        view.addSubview(titleLabel)
        
        if UIScreen.main.isSmall {
            titleLabel.autoPinEdge(.leading, to: .trailing, of: backButton, withOffset: 24)
            titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
        } else {
            titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            titleLabel.autoPinEdge(.top, to: .bottom, of: backButton, withOffset: 10)
        }
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdge(.top, to: .bottom, of: titleLabel)
        scrollView.autoPinEdge(toSuperviewEdge: .leading)
        scrollView.autoPinEdge(toSuperviewEdge: .trailing)
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        // textfields
        scrollView.contentView.addSubview(loginTextField)
        loginTextField.autoPinEdge(toSuperviewEdge: .top, withInset: UIScreen.main.isSmall ? 20 : 50)
        loginTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        
        scrollView.contentView.addSubview(passwordTextField)
        passwordTextField.autoPinEdge(.top, to: .bottom, of: loginTextField, withOffset: 12)
        passwordTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // paste
        pasteFromClipboardButton.titleLabel?.numberOfLines = 0
        scrollView.contentView.addSubview(pasteFromClipboardButton)
        pasteFromClipboardButton.autoPinEdge(.top, to: .bottom, of: passwordTextField, withOffset: 10)
        pasteFromClipboardButton.autoPinEdge(.leading, to: .leading, of: loginTextField)
        pasteFromClipboardButton.autoPinEdge(.trailing, to: .trailing, of: loginTextField)
        
        // sing in button
        scrollView.contentView.addSubview(signInButton)
        signInButton.autoPinEdge(.top, to: .bottom, of: passwordTextField, withOffset: 40 * Config.heightRatio)
        signInButton.autoPinEdge(.leading, to: .leading, of: loginTextField)
        signInButton.addTarget(self, action: #selector(signInButtonDidTouch), for: .touchUpInside)
        
        // qr code
        scrollView.contentView.addSubview(scanQrCodeButton)
        scanQrCodeButton.autoAlignAxis(.horizontal, toSameAxisOf: signInButton)
        scanQrCodeButton.autoPinEdge(.leading, to: .trailing, of: signInButton, withOffset: 5)
        scanQrCodeButton.autoPinEdge(.trailing, to: .trailing, of: loginTextField)
        scanQrCodeButton.addTarget(self, action: #selector(scanQrButtonDidTouch), for: .touchUpInside)
        
        // sign up button
        scrollView.contentView.addSubview(signUpButton)
        signUpButton.autoPinEdge(.top, to: .bottom, of: signInButton, withOffset: 20)
        signUpButton.autoAlignAxis(toSuperviewAxis: .vertical)
        signUpButton.autoPinEdge(toSuperviewSafeArea: .bottom)
        signUpButton.addTarget(self, action: #selector(signUpButtonDidTouch), for: .touchUpInside)
        
        // retrieve icloud key-value
        #if !APPSTORE
            let keyStore = NSUbiquitousKeyValueStore()
            if let login = keyStore.string(forKey: Config.currentUserNameKey),
                let key = keyStore.string(forKey: Config.currentUserMasterKey) {
                setTextfieldWithLogin(login, key: key)
            }
        #endif
        
        // dismiss keyboard
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func bind() {
        super.bind()
        // Validator
        Observable.combineLatest(
            loginTextField.rx.text,
            passwordTextField.rx.text
        )
            .filter {$0 != nil && $1 != nil}
            .map {LoginCredential(login: $0!, key: $1!)}
            .subscribe(onNext: { cred in
                self.signInButton.isEnabled = self.validate(cred: cred)
            })
            .disposed(by: disposeBag)
        
        loginTextField.rx.controlEvent(.editingChanged)
            .subscribe(onNext: { _ in
                self.loginTextField.text = self.loginTextField.text?.lowercased()
            })
            .disposed(by: disposeBag)
    }
    
    func setTextfieldWithLogin(_ login: String, key: String) {
        self.loginTextField.text = login
        self.passwordTextField.text = key
        self.loginTextField.sendActions(for: .valueChanged)
        self.passwordTextField.sendActions(for: .valueChanged)
    }
    
    func configure(signingIn: Bool) {
        if signingIn {
            self.showIndetermineHudWithMessage("signing in".localized().uppercaseFirst + "...")
        } else {
            self.hideHud()
        }
        
        signInButton.isEnabled = !signingIn
        self.signUpButton.isEnabled = !signingIn
    }
    
    func validate(cred: LoginCredential) -> Bool {
        return cred.login.count > 3 && cred.key.count >= AuthManager.minPasswordLength
    }
    
    // MARK: - Actions
    @objc func signUpButtonDidTouch() {
        let nc = self.navigationController
        navigationController?.popViewController(animated: true, {
            let signUpVC = SignUpVC()
            nc?.pushViewController(signUpVC)
        })
    }
    
    @objc func signInButtonDidTouch() {
        // signing state
        view.endEditing(true)
        configure(signingIn: true)
        
        // send request
        viewModel.signIn(
            login: loginTextField.text!.trimmingCharacters(in: .whitespaces),
            masterKey: passwordTextField.text!.trimmingCharacters(in: .whitespaces)
            )
            .subscribe(onCompleted: {
                AnalyticsManger.shared.signInStatus(success: true)
                AuthManager.shared.reload()
            }, onError: { [weak self] (error) in
                AnalyticsManger.shared.signInStatus(success: false)
                self?.configure(signingIn: false)
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func scanQrButtonDidTouch() {
        let vc = QRScannerViewController()
        vc.completion = { credential in
            self.setTextfieldWithLogin(credential.login, key: credential.key)
            self.signInButtonDidTouch()
        }
        show(vc, sender: nil)
    }
}

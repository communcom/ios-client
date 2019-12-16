//
//  SignInVC.swift
//  Commun
//
//  Created by Chung Tran on 12/9/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

typealias LoginCredential = (login: String, key: String)

class SignInVC: BaseViewController {
    // MARK: - Properties
    let paddingX: CGFloat = 43 * Config.heightRatio
    let viewModel = SignInViewModel()
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(forAutoLayout: ())
    
    lazy var loginTextField: UITextField = {
        let textField = createTextField()
        textField.placeholder = "login".localized().uppercaseFirst
        textField.rx.controlEvent(.editingChanged)
            .subscribe(onNext: { _ in
                textField.text = textField.text?.lowercased()
            })
            .disposed(by: disposeBag)
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = createTextField()
        textField.placeholder = "key".localized().uppercaseFirst
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        return textField
    }()
    
    lazy var pasteFromClipboardButton = UIButton(labelFont: .systemFont(ofSize: 15), textColor: .appMainColor)
    
    lazy var signInButton = CommunButton.default(height: 56, label: "sign in".localized().uppercaseFirst, cornerRadius: 8)
    lazy var signUpButton = UIButton(label: "don't have an account?".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15 * Config.heightRatio), textColor: .appMainColor)
    
    lazy var scanQrCodeButton = UIButton.roundedCorner(8, size: 56 * Config.heightRatio, backgroundColor: .appMainColor, tintColor: .white, imageName: "scan-qr-code")
    
    // MARK: - Methods
    private func createTextField() -> UITextField {
        let textField = UITextField(height: 56 * Config.heightRatio, backgroundColor: .f3f5fa, cornerRadius: 12 * Config.heightRatio)
        textField.font = .systemFont(ofSize: 17 * Config.heightRatio)
        let paddingView: UIView = UIView(width: 16, height: 20)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }
    
    override func setUp() {
        super.setUp()
        // title
        title = "welcome".localized().uppercaseFirst
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        setNavBarBackButton()
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        // textfields
        scrollView.contentView.addSubview(loginTextField)
        loginTextField.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 54 * Config.heightRatio, left: paddingX, bottom: 0, right: paddingX), excludingEdge: .bottom)
        
        scrollView.contentView.addSubview(passwordTextField)
        passwordTextField.autoPinEdge(.top, to: .bottom, of: loginTextField, withOffset: 12)
        passwordTextField.autoPinEdge(toSuperviewEdge: .leading, withInset: paddingX)
        passwordTextField.autoPinEdge(toSuperviewEdge: .trailing, withInset: paddingX)
        
        // paste
        scrollView.contentView.addSubview(pasteFromClipboardButton)
        pasteFromClipboardButton.autoPinEdge(.top, to: .bottom, of: passwordTextField, withOffset: 10)
        pasteFromClipboardButton.autoPinEdge(toSuperviewEdge: .leading, withInset: paddingX)
        pasteFromClipboardButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: paddingX)
        
        // sing in button
        scrollView.contentView.addSubview(signInButton)
        signInButton.autoPinEdge(.top, to: .bottom, of: passwordTextField, withOffset: 40 * Config.heightRatio)
        signInButton.autoPinEdge(toSuperviewEdge: .leading, withInset: paddingX)
        signInButton.addTarget(self, action: #selector(signInButtonDidTouch), for: .touchUpInside)
        
        // qr code
        scrollView.contentView.addSubview(scanQrCodeButton)
        scanQrCodeButton.autoAlignAxis(.horizontal, toSameAxisOf: signInButton)
        scanQrCodeButton.autoPinEdge(.leading, to: .trailing, of: signInButton, withOffset: 5)
        scanQrCodeButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: paddingX)
        scanQrCodeButton.addTarget(self, action: #selector(scanQrButtonDidTouch), for: .touchUpInside)
        
        // sign up button
        scrollView.contentView.addSubview(signUpButton)
        signUpButton.autoPinEdge(.top, to: .bottom, of: signInButton, withOffset: 20)
        signUpButton.autoAlignAxis(toSuperviewAxis: .vertical)
        signUpButton.autoPinEdge(toSuperviewSafeArea: .bottom)
        signUpButton.addTarget(self, action: #selector(signUpButtonDidTouch), for: .touchUpInside)
        
        // retrieve icloud key-value
        let keyStore = NSUbiquitousKeyValueStore()
        if let login = keyStore.string(forKey: Config.currentUserNameKey),
            let key = keyStore.string(forKey: Config.currentUserMasterKey)
        {
            setTextfieldWithLogin(login, key: key)
        }
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
        return cred.login.count > 3 && cred.key.count > 10
    }
    
    // MARK: - Actions
    @objc func signUpButtonDidTouch() {
        let nc = self.navigationController
        navigationController?.popViewController(animated: true, {
            let signUpVC = controllerContainer.resolve(SignUpVC.self)!
            nc?.pushViewController(signUpVC)
        })
    }
    
    @objc func signInButtonDidTouch() {
        // signing state
        view.endEditing(true)
        configure(signingIn: true)
        
        // send request
        viewModel.signIn(
            login:      loginTextField.text!.trimmingCharacters(in: .whitespaces),
            masterKey:  passwordTextField.text!.trimmingCharacters(in: .whitespaces)
            )
            .subscribe(onCompleted: {
                AppDelegate.reloadSubject.onNext(true)
            }, onError: { [weak self] (error) in
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

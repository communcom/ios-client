//
//  SignInViewController.swift
//  Commun
//
//  Created by Chung Tran on 27/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import QRCodeReaderViewController

class SignInViewController: UIViewController {
    // Selection
    var selected = 1 {
        didSet {
            self.view.endEditing(true)
        }
    }
    var selection = ["Scan QR".localized(), "Login & Key".localized()]
    
    // Views
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var qrContainerView: UIView!
    @IBOutlet weak var qrCodeReaderView: UIView!
    
    @IBOutlet var loginPasswordContainerView: UIView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    var qrReaderVC: QRCodeReaderViewController!
    
    // Properties
    let viewModel = SignInViewModel()
    let disposeBag = DisposeBag()
    
    // Handlers
    var handlerSignUp: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        bind()
    }
    
    func setUpViews() {
        // title
        title = "Welcome".localized()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Configure textView
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        loginTextField.leftView = paddingView
        loginTextField.leftViewMode = .always
        
        let paddingView2: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        passwordTextField.leftView = paddingView2
        passwordTextField.leftViewMode = .always
    }
    
    func bind() {
        // Validator
        let validator = Observable.combineLatest(
            loginTextField.rx.text,
            passwordTextField.rx.text
        )
            .filter {$0 != nil && $1 != nil}
            .map {LoginCredential(login: $0!, key: $1!)}
            .share()
        
        validator
            .subscribe(onNext: { cred in
                _ = self.checkCorrectDataAndSetupButton(cred)
            })
            .disposed(by: disposeBag)
        
        // Login action
        signInButton.rx.tap
            .withLatestFrom(validator.filter(checkCorrectDataAndSetupButton))
            .flatMapLatest({ (cred) -> Observable<String> in
                return self.viewModel.signIn(withLogin: cred.login, withApiKey: cred.key)
                    .do(onSubscribed: { [weak self] in
                        self?.configure(signingIn: true)
                    })
                    .catchError {[weak self] _ in
                        self?.configure(signingIn: false)
                        self?.showAlert(title: nil, message: "Login error".localized() + ".\n" + "Please try again later".localized())
                        return Observable<String>.empty()
                }
            })
            .subscribe(onNext: {_ in
                self.configure(signingIn: false)
                WebSocketManager.instance.authorized.accept(true)
            })
            .disposed(by: disposeBag)
        
        // Switch to sign up
        signUpButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                strongSelf.navigationController?.popViewController(animated: true, {
                    strongSelf.handlerSignUp!(true)
                })
            })
            .disposed(by: disposeBag)
        
        // qr code
        viewModel.qrCode
            .skip(1)
            .subscribe(onNext: {[weak self] (login, key) in
                self?.selectMethod(index: 1)
                self?.loginTextField.text = login
                self?.loginTextField.sendActions(for: .valueChanged)
                self?.passwordTextField.text = key
                self?.passwordTextField.sendActions(for: .valueChanged)
                self?.signInButton.sendActions(for: .touchUpInside)
            })
            .disposed(by: disposeBag)
    }
    
    func configure(signingIn: Bool) {
        if signingIn {
            self.showIndetermineHudWithMessage("Signing in".localized() + "...")
        } else {
            self.hideHud()
        }
        self.signInButton.isEnabled = !signingIn
        self.signInButton.backgroundColor = signingIn ? #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 0.3834813784) : #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1)
        self.signUpButton.isEnabled = !signingIn
    }
    
    func checkCorrectDataAndSetupButton(_ cred: LoginCredential) -> Bool {
        if cred.login.count > 3 && cred.key.count > 10 {
            signInButton.isEnabled = true
            signInButton.backgroundColor = #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1)
            return true
        }
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 0.3834813784)
        return false
    }

}

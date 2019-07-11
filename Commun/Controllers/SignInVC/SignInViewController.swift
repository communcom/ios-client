//
//  SignInViewController.swift
//  Commun
//
//  Created by Chung Tran on 27/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
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
    @IBOutlet weak var signInButton: StepButton!
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
        
        // retrieve icloud key-value
        let keyStore = NSUbiquitousKeyValueStore()
        if let login = keyStore.string(forKey: Config.currentUserIDKey),
            let key = keyStore.string(forKey: Config.currentUserPublicActiveKey)
        {
            setTextfieldWithLogin(login, key: key)
        }
    }
    
    func bind() {
        // Validator
        let validator = Observable.combineLatest(
            loginTextField.rx.text,
            passwordTextField.rx.text
        )
            .filter {$0 != nil && $1 != nil}
            .map {LoginCredential(login: $0!, key: $1!)}
        
        validator
            .subscribe(onNext: { cred in
                self.signInButton.isEnabled = self.validate(cred: cred)
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
                self?.setTextfieldWithLogin(login, key: key)
                self?.signInButton.sendActions(for: .touchUpInside)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func signInButtonDidTouch(_ sender: Any) {
        // signing state
        view.endEditing(true)
        configure(signingIn: true)
        
        // send request
        viewModel.signIn(
                withLogin: loginTextField.text!,
                withApiKey: passwordTextField.text!
            )
            .catchError { error in
                if let error = error as? ErrorAPI {
                    if error.caseInfo.message == "There is no secret stored for this channelId. Probably, client's already authorized" {
                        return .empty()
                    }
                }
                throw error
            }
            .subscribe(onCompleted: { [weak self] in
                self?.configure(signingIn: false)
            }, onError: { [weak self] (error) in
                self?.configure(signingIn: false)
                self?.showError(error)
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
            self.showIndetermineHudWithMessage("Signing in".localized() + "...")
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
    @IBAction func debugButtonTapped(_ sender: UIButton) {
        Broadcast.instance.generateNewTestUser { [weak self] (newUser) in
            guard let strongSelf = self, let user = newUser else { return }
            
            let login       =   user.username
            let activeKey   =   user.active_key

            DispatchQueue.main.async {
                strongSelf.loginTextField.text = login
                strongSelf.passwordTextField.text = activeKey
                strongSelf.loginTextField.becomeFirstResponder()
                strongSelf.passwordTextField.becomeFirstResponder()
                strongSelf.passwordTextField.resignFirstResponder()
            }
        }
    }
}

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
    // MARK: - Properties
    var selected = 1 {
        didSet {
            self.view.endEditing(true)
        }

    }
    
    var selection = ["scan QR".localized().uppercaseFirst, "login & key".localized().uppercaseFirst]
    
    var qrReaderVC: QRCodeReaderViewController!
    
    // Properties
    let viewModel = SignInViewModel()
    let disposeBag = DisposeBag()
    
    // Handlers
    var handlerSignUp: ((Bool) -> Void)?
    

    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var qrContainerView: UIView!
    @IBOutlet weak var qrCodeReaderView: UIView!
    
    @IBOutlet weak var signInButton: StepButton!
    @IBOutlet weak var signUpButton: BlankButton!
    
    @IBOutlet var loginPasswordContainerView: UIView!
    
    @IBOutlet weak var loginTextField: UITextField! {
        didSet {
            self.loginTextField.tune(withPlaceholder:       "login placeholder",
                                     textColors:            blackWhiteColorPickers,
                                     font:                  UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                     alignment:             .left)
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            self.passwordTextField.tune(withPlaceholder:    "key placeholder",
                                        textColors:         blackWhiteColorPickers,
                                        font:               UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                        alignment:          .left)
        }
    }
    
    @IBOutlet weak var gotoLabel: UILabel! {
        didSet {
            self.gotoLabel.tune(withText:       "go to commun.com and scan QR".localized().uppercaseFirst,
                                hexColors:      blackWhiteColorPickers,
                                font:           UIFont.init(name: "SFProText-Regular", size: 17.0 * Config.widthRatio),
                                alignment:      .center,
                                isMultiLines:   true)
        }
    }
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        bind()
    }
    
    
    // MARK: - Custom Functions
    func setUpViews() {
        // title
        title = "welcome".localized().uppercaseFirst
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        self.setNavBarBackButton()

        // collection View
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: true)
        
        // Configure textView
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        loginTextField.leftView = paddingView
        loginTextField.leftViewMode = .always
        
        let paddingView2: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        passwordTextField.leftView = paddingView2
        passwordTextField.leftViewMode = .always
        
        // retrieve icloud key-value
        let keyStore = NSUbiquitousKeyValueStore()
        if let login = keyStore.string(forKey: Config.currentUserNameKey),
            let key = keyStore.string(forKey: Config.currentUserMasterKey)
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
    @IBAction func signInButtonDidTouch(_ sender: Any) {
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
}

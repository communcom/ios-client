//
//  SignInVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 26/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift

typealias LoginCredential = (login: String, key: String)

class SignInVC: UIViewController {
    // MARK: - Properties
    let viewModel = SignInViewModel()
    let disposeBag = DisposeBag()

    // Handlers
    var handlerSignUp: ((Bool) -> Void)?
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var textLabel1: UILabel! {
        didSet {
            self.textLabel1.tune(withText:      "Welcome,".localized(),
                                 hexColors:     blackWhiteColorPickers,
                                 font:          UIFont(name: "SFProDisplay-Bold", size: 34.0 * Config.heightRatio),
                                 alignment:     .left,
                                 isMultiLines:  false)
        }
    }
    
    @IBOutlet weak var textLabel2: UILabel! {
        didSet {
            self.textLabel2.tune(withText:      "sign in to continue".localized(),
                                 hexColors:     softBlueColorPickers,
                                 font:          UIFont(name: "SFProDisplay-Bold", size: 34.0 * Config.heightRatio),
                                 alignment:     .left,
                                 isMultiLines:  false)
        }
    }
    
    @IBOutlet weak var loginTextField: UITextField! {
        didSet {
            self.loginTextField.tune(withPlaceholder:   "Login Placeholder".localized(),
                                     textColors:        blackWhiteColorPickers,
                                     font:              UIFont(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                     alignment:         .left)
            
            self.loginTextField.layer.cornerRadius = 12.0 * Config.heightRatio
            self.loginTextField.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var keyTextField: UITextField! {
        didSet {
            self.keyTextField.tune(withPlaceholder:   "Key Placeholder".localized(),
                                   textColors:        blackWhiteColorPickers,
                                   font:              UIFont(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                   alignment:         .left)

            self.keyTextField.layer.cornerRadius = 12.0 * Config.heightRatio
            self.keyTextField.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            self.signInButton.tune(withTitle:     "Sign in".localized(),
                                   hexColors:     [whiteBlackColorPickers, veryLightGrayColorPickers, veryLightGrayColorPickers, veryLightGrayColorPickers],
                                   font:          UIFont(name: "SFProText-Semibold", size: 17.0 * Config.heightRatio),
                                   alignment:     .center)
            
            self.signInButton.layer.cornerRadius = 8.0 * Config.heightRatio
            self.signInButton.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            self.signUpButton.tune(withTitle:     "Don't have an account?".localized(),
                                   hexColors:     [softBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers, verySoftBlueColorPickers],
                                   font:          UIFont(name: "SFProText-Semibold", size: 15.0 * Config.heightRatio),
                                   alignment:     .center)
        }
    }
    
    @IBOutlet var heightsCollection: [NSLayoutConstraint]! {
        didSet {
            self.heightsCollection.forEach({ $0.constant *= Config.heightRatio })
        }
    }

    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        let keyPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        
        loginTextField.leftView = loginPaddingView
        loginTextField.leftViewMode = .always
        
        keyTextField.leftView = keyPaddingView
        keyTextField.leftViewMode = .always
        
        makeSubscriptions()        
    }
    
    func makeSubscriptions() {
        let validator = Observable.combineLatest(loginTextField.rx.text, keyTextField.rx.text)
            .filter {$0 != nil && $1 != nil}
            .map {LoginCredential(login: $0!, key: $1!)}
            .share()
        
        validator
            .subscribe(onNext: { cred in
                _ = self.checkCorrectDataAndSetupButton(cred)
            })
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .withLatestFrom(validator.filter(checkCorrectDataAndSetupButton))
            .flatMapLatest({ (cred) -> Observable<String> in
                return self.viewModel.signIn(withLogin: cred.login, withApiKey: cred.key)
                    .catchError {[weak self] _ in
                        self?.showAlert(title: nil, message: "Login error.\nPlease try again later")
                        return Observable<String>.empty()
                    }
            })
            .subscribe {[weak self] completable in
                switch completable {
                case .completed, .error(_):
                    break
                case .next(_):
                    self?.present(TabBarVC(), animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                strongSelf.navigationController?.popViewController(animated: true, {
                    strongSelf.handlerSignUp!(true)
                })
            })
            .disposed(by: disposeBag)
        
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
    
    
    // MARK: - Gestures
    @IBAction func handlerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

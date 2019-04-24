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
//import IHProgressHUD

typealias LoginCredential = (login: String, key: String)

class SignInVC: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    let viewModel = SignInViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        let keyPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        
        loginTextField.leftView = loginPaddingView
        loginTextField.leftViewMode = .always
        
        keyTextField.leftView = keyPaddingView
        keyTextField.leftViewMode = .always
        
        
        makeSubscriptions()
        
        let attributedString = NSMutableAttributedString(string: "Welcome,\nsign in to continue")
        
        let attributes1: [NSAttributedString.Key : Any] = [
            .foregroundColor: #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        ]
        attributedString.addAttributes(attributes1, range: NSRange(location: 9, length: 19))
        welcomeLabel.attributedText = attributedString
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
//                IHProgressHUD.set(foregroundColor: #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1))
//                IHProgressHUD.show()
                return self.viewModel.signIn(withLogin: cred.login, withApiKey: cred.key)
                    .catchError {[weak self] _ in
//                        DispatchQueue.global(qos: .default).async(execute: {
//                            IHProgressHUD.dismiss()
//                        })
                        self?.showAlert(title: nil, message: "Login error.\nPlease try again later")
                        return Observable<String>.empty()
                    }
            })
            .subscribe {[weak self] completable in
                DispatchQueue.global(qos: .default).async(execute: {
//                    IHProgressHUD.dismiss()
                })
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
                self?.showAlert(title: "TODO", message: "SignUp")
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
}

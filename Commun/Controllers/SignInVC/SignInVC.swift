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
import IHProgressHUD

class SignInVC: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
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
        checkCorrectDataAndSetupButton()
        
        let attributedString = NSMutableAttributedString(string: "Welcome,\nsign in to continue")
        
        let attributes1: [NSAttributedString.Key : Any] = [
            .foregroundColor: #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        ]
        attributedString.addAttributes(attributes1, range: NSRange(location: 9, length: 19))
        welcomeLabel.attributedText = attributedString
    }

    @IBAction func signInButtonTap(_ sender: Any) {
        IHProgressHUD.set(foregroundColor: #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1))
        IHProgressHUD.show()
        viewModel.signIn(withLogin: loginTextField.text!, withApiKey: keyTextField.text!)
    }
    
    @IBAction func dontHaveAccountButtonTap(_ sender: Any) {
        showAlert(title: "TODO", message: "SignUp")
    }
    
    func makeSubscriptions() {
        viewModel.errorSubject.subscribe(onNext: { [weak self] errorText in
            self?.showAlert(title: nil, message: errorText)
        }).disposed(by: disposeBag)
     
        viewModel.errorSubject.subscribe {
            DispatchQueue.global(qos: .default).async(execute: {
                IHProgressHUD.dismiss()
            })
            self.present(TabBarVC(), animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        loginTextField.rx.text.subscribe(onNext: { [weak self] _ in
            self?.checkCorrectDataAndSetupButton()
        }).disposed(by: disposeBag)
        
        keyTextField.rx.text.subscribe(onNext: { [weak self] _ in
            self?.checkCorrectDataAndSetupButton()
        }).disposed(by: disposeBag)
    }
    
    func checkCorrectDataAndSetupButton() {
        if viewModel.checkCorrectUserData(login: loginTextField.text ?? "", key: keyTextField.text ?? "") {
            signInButton.isEnabled = true
            signInButton.backgroundColor = #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1)
        } else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 0.3834813784)
        }
        
    }
}

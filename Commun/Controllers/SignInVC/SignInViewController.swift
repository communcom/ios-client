//
//  SignInViewController.swift
//  Commun
//
//  Created by Chung Tran on 27/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit


class SignInViewController: UIViewController {
    // Selection
    var selected = 1 {
        didSet {
            self.view.endEditing(true)
        }
    }
    var selection = ["Scan QR".localized(), "Login & Key".localized()]
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var qrContainerView: UIView!
    
    @IBOutlet var loginPasswordContainerView: UIView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    // Handlers
    var handlerSignUp: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        bind()
    }
    
    func setUpViews() {
        // Configure textView
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        loginTextField.leftView = paddingView
        loginTextField.leftViewMode = .always
        
        let paddingView2: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        passwordTextField.leftView = paddingView2
        passwordTextField.leftViewMode = .always
    }
    
    func bind() {
        
    }

}

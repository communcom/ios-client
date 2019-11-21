//
//  WelcomeVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import SwiftTheme

class WelcomeVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var nextButton: StepButton!
    
    @IBOutlet weak var bottomSignInButton: StepButton! {
        didSet {
            self.bottomSignInButton.isHidden = true
        }
    }

    @IBOutlet weak var topSignInButton: BlankButton! {
        didSet {
            self.topSignInButton.commonInit(hexColors:     [blackWhiteColorPickers, grayishBluePickers, grayishBluePickers, grayishBluePickers],
                                         font:          UIFont(name: "SFProText-Medium", size: .adaptive(width: 15.0)),
                                         alignment:     .right)
        }
    }
    
    @IBOutlet var actionButtonsCollection: [StepButton]! {
        didSet {
            self.actionButtonsCollection.forEach {
                $0.commonInit(backgroundColor: UIColor(hexString: "#6A80F5"),
                              font:            .boldSystemFont(ofSize: CGFloat.adaptive(width: 15.0)),
                              cornerRadius:    $0.height / CGFloat.adaptive(height: 2.0))
            }
        }
    }
    
    @IBOutlet weak var signUpButton: StepButton! {
        didSet {
            self.signUpButton.commonInit(backgroundColor: UIColor(hexString: "#F3F5FA"),
                                       font:            .boldSystemFont(ofSize: CGFloat.adaptive(width: 15.0)),
                                       cornerRadius:    self.signUpButton.height / CGFloat.adaptive(height: 2.0))
            self.signUpButton.isHidden = true
        }
    }
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    // MARK: - Custom Functions
    func navigateToSignUp() {
        let signUpVC = controllerContainer.resolve(SignUpVC.self)!
        show(signUpVC, sender: nil)
    }

    
    // MARK: - Actions
    @IBAction func signInButtonTap(_ sender: Any) {
        let signInVC = controllerContainer.resolve(SignInViewController.self)!
        
        signInVC.handlerSignUp = { [weak self] success in
            guard let strongSelf = self else { return }
            
            if success {
                strongSelf.navigateToSignUp()
            }
        }
        
        navigationController?.pushViewController(signInVC)
    }
    
    @IBAction func signUpButtonTap(_ sender: Any) {
        self.navigateToSignUp()
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
    }
}

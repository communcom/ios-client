//
//  WelcomeVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift

class WelcomeVC: UIViewController {
    
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
        navigateToSignUp()
    }
    
    func navigateToSignUp() {
        let signUpVC = controllerContainer.resolve(SignUpVC.self)!
        show(signUpVC, sender: nil)
    }
}

//
//  WelcomeVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    var router: (NSObjectProtocol & SignUpRoutingLogic)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "FirstStart")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        let router                  =   SignUpRouter()
        router.viewController       =   self
        self.router                 =   router
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
        self.router?.routeToSignInScene()
    }
    
    @IBAction func signUpButtonTap(_ sender: Any) {
        self.router?.routeToSignUpNextScene()
    }
}

//
//  WelcomeVC.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WelcomeVC: BaseViewController {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var topSignInButton = UIButton(label: "sign in".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .semibold))
    lazy var pageControl = CMPageControll(numberOfPages: 3)
    
    // MARK: - Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func setUp() {
        super.setUp()
        // navigation bar
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        navigationBarAppearace.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: .adaptive(width: 30), weight: .bold)
        ]
        
        // if signUp is processing
        if KeychainManager.currentUser()?.registrationStep != nil
        {
            navigateToSignUp()
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // top sign in button
        view.addSubview(topSignInButton)
        topSignInButton.autoPinTopAndTrailingToSuperViewSafeArea()
        
        // page control
        view.addSubview(pageControl)
        pageControl.autoAlignAxis(.horizontal, toSameAxisOf: topSignInButton)
        pageControl.autoAlignAxis(toSuperviewAxis: .vertical)
        
        
        
        pageControl.selectedIndex = 0
    }
    
    // MARK: - Actions
    func navigateToSignUp() {
        let controller = SignUpVC()
        show(controller, sender: nil)
    }
}

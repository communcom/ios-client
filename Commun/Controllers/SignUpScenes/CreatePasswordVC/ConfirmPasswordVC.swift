//
//  ConfirmPasswordVC.swift
//  Commun
//
//  Created by Chung Tran on 3/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ConfirmPasswordVC: CreatePasswordVC {
    // MARK: - Properties
    var currentPassword: String
    
    // MARK: - Initializers
    init(currentPassword: String) {
        self.currentPassword = currentPassword
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        titleLabel.text = "confirm password".localized().uppercaseFirst
        if UIDevice.current.screenType != .iPhones_5_5s_5c_SE {
            let label = UILabel.with(text: "re-enter your password".localized().uppercaseFirst, textSize: 17)
            scrollView.contentView.addSubview(label)
            label.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        }
    }
    
    override func setUpGenerateMasterPasswordButton() {
        // do nothing
    }
    
    override func backButtonDidTouch() {
        back()
    }
    
    override func validationDidComplete() {
        guard currentPassword == textField.text else {
            showErrorWithLocalizedMessage("passwords do not match")
            return
        }
        
        self.view.endEditing(true)
        
        self.showIndetermineHudWithMessage("saving to blockchain")
        RestAPIManager.instance.toBlockChain(password: currentPassword)
            .subscribe(onCompleted: {
                AuthManager.shared.reload()
                self.savePasswordToIcloud()
            }) { (error) in
                self.hideHud()
                self.handleSignUpError(error: error)
            }
            .disposed(by: self.disposeBag)
    }

    private func savePasswordToIcloud() {
        if let user = Config.currentUser, let userName = user.name, let password = user.masterKey {
                   var domain = "dev.commun.com"
                   #if APPSTORE
                       domain = "commun.com"
                   #endif

                   SecAddSharedWebCredential(domain as CFString, userName as CFString, password as CFString) { (error) in
                       if error != nil {
                           AnalyticsManger.shared.passwordBackuped()
                       }
                   }
               }
    }
}

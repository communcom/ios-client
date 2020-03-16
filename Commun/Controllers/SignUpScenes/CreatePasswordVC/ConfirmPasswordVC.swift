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
    
    override func backButtonDidTouch() {
        back()
    }
    
    override func validationDidComplete() {
        guard currentPassword == textField.text else {
            showErrorWithLocalizedMessage("passwords do not match")
            return
        }
        
        self.view.endEditing(true)
        
        try! RestAPIManager.instance.setPassword(currentPassword)
        
        self.showIndetermineHudWithMessage("saving to blockchain")
        RestAPIManager.instance.toBlockChain()
            .subscribe(onCompleted: {
                AuthManager.shared.reload()
            }) { (error) in
                self.hideHud()
                self.handleSignUpError(error: error)
            }
            .disposed(by: self.disposeBag)
    }
}

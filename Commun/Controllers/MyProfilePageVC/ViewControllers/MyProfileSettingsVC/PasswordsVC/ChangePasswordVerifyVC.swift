//
//  ChangePasswordVerifyVC.swift
//  Commun
//
//  Created by Chung Tran on 8/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ChangePasswordVerifyVC: ConfirmPasswordVC {
    var completion: (() -> Void)?
    
    override func sendData() {
        showIndetermineHudWithMessage("changing password".localized().uppercaseFirst)
        BlockchainManager.instance.changePassword(currentPassword)
            .flatMapToCompletable()
            .subscribe(onCompleted: {
                self.hideHud()
                self.completion?()
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}

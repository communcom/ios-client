//
//  ChangePasswordUsingMasterPasswordVC.swift
//  Commun
//
//  Created by Chung Tran on 8/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ChangePasswordUsingMasterPasswordVC: GenerateMasterPasswordVC {
    var completion: (() -> Void)?
    override func handlePassword(saveToIcloud: Bool = false) {
        showIndetermineHudWithMessage("changing password".localized().uppercaseFirst)
        BlockchainManager.instance.changePassword(masterPassword!)
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

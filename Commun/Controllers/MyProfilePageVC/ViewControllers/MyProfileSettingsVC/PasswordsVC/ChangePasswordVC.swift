//
//  ChangePasswordVC.swift
//  Commun
//
//  Created by Chung Tran on 8/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ChangePasswordVC: CreatePasswordVC {
    var completion: (() -> Void)?
    
    override func validationDidComplete() {
        guard let currentPassword = textField.text else {return}
        view.endEditing(true)

        AnalyticsManger.shared.passwordEntered(available: true)
        // fix animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let confirmVC = ChangePasswordVerifyVC(currentPassword: currentPassword)
            
            confirmVC.completion = {
                confirmVC.back()
                self.completion?()
                self.back()
            }
            
            self.show(confirmVC, sender: nil)
        }
    }
}

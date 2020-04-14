//
//  VerifyUserVC.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class VerifyPhoneVC: BaseVerifyVC {
    
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.registrationOpenScreen(3)
        
        subtitleLabel.text = "enter sms-code".localized().uppercaseFirst
    }
    
    override func resendButtonTapped() {
        guard KeychainManager.currentUser()?.phoneNumber != nil else {
            try? KeychainManager.deleteUser()
            // Go back
            popToPreviousVC()
            return
        }
        
        AnalyticsManger.shared.smsCodeResend()
        
        RestAPIManager.instance.resendSmsCode()
            .subscribe(onSuccess: { [weak self] (_) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.checkResendSmsCodeTime()
                    self.showAlert(title: "info".localized().uppercaseFirst,
                                   message: "successfully resend code".localized().uppercaseFirst)
                }
            }) { [weak self] (error) in
                self?.showError(error)
        }
        .disposed(by: disposeBag)
    }
    
    override func sendCodeToVerify(_ code: UInt64) {
        AnalyticsManger.shared.smsCodeEntered()
        
        showIndetermineHudWithMessage("verifying...".localized().uppercaseFirst)
        
        RestAPIManager.instance.verify(code: code)
            .subscribe(onSuccess: { [weak self] (_) in
                AnalyticsManger.shared.smsCodeRight()
                self?.hideHud()
                self?.signUpNextStep()
            }) { (error) in
                self.deleteCode()
                AnalyticsManger.shared.smsCodeError()
                self.hideHud()
                self.handleSignUpError(error: error)
        }
        .disposed(by: disposeBag)
    }
}

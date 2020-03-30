//
//  VerifyPhoneVC.swift
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
    
    // MARK: - accessoryView
    //    func addAccessoryView(withSmsCode smsCode: String) {
    //        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: .adaptive(height: 44.0)))
    //        let smsCodeButton = UIBarButtonItem(title: smsCode, style: .plain, target: self, action: #selector(smsCodeButtonTapped(button:)))
    //        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    //        toolBar.items = [spacer, smsCodeButton, spacer]
    //        toolBar.tintColor = UIColor(hexString: "#6A80F5")
    //        pinCodeInputView.inputAccessoryView = toolBar
    //    }
    //
    //    func removeAccessoryView() {
    //        pinCodeInputView.inputAccessoryView = nil
    //    }
    
    //    @objc func smsCodeButtonTapped(button: UIBarButtonItem) {
    //        pinCodeInputView.insertText(button.title!)
    //        removeAccessoryView()
    //    }
}

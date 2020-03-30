//
//  VerifyPhoneVC.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class VerifyPhoneVC: BaseVerifyVC {
    
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.registrationOpenScreen(3)
        
        subtitleLabel.text = "enter sms-code".localized().uppercaseFirst
    }
    
    override func getNextRetry() -> Date? {
        guard let user = KeychainManager.currentUser(),
            user.registrationStep == .verify,
            let date = user.smsNextRetry?.convert(toDateFormat: .nextSmsDateType)
            else {
                return nil
        }
        return date
    }
    
    override var resendCodeCompletable: Completable {
        RestAPIManager.instance.resendSmsCode().flatMapToCompletable()
    }
    
    override func resendButtonTapped() {
        guard KeychainManager.currentUser()?.phoneNumber != nil else {
            try? KeychainManager.deleteUser()
            // Go back
            popToPreviousVC()
            return
        }
        AnalyticsManger.shared.smsCodeResend()
        super.resendButtonTapped()
    }
    
    override func createVerificationRequest(code: UInt64) -> Completable {
        AnalyticsManger.shared.smsCodeEntered()
        
        return RestAPIManager.instance.verify(code: code).flatMapToCompletable()
            .do(onError: { (error) in
                AnalyticsManger.shared.smsCodeError()
            }, onCompleted: {
                AnalyticsManger.shared.smsCodeRight()
            })
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

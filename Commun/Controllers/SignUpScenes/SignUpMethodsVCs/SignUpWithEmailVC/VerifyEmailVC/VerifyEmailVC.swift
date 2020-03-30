//
//  VerifyEmailVC.swift
//  Commun
//
//  Created by Chung Tran on 3/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class VerifyEmailVC: BaseVerifyVC {
    
    override func setUp() {
        super.setUp()
        // TODO: - Analystic manager
//        AnalyticsManger.shared.registrationOpenScreen(3)
        
        subtitleLabel.text = "an email has been sent with the verification code. Please enter it here".localized().uppercaseFirst
        subtitleLabel.textColor = .a5a7bd
    }
    
    override func getNextRetry() -> Date? {
        guard let user = KeychainManager.currentUser(),
            user.registrationStep == .verifyEmail,
            let date = user.emailNextRetry?.convert(toDateFormat: .nextSmsDateType)
            else {
                return nil
            }
        return date
    }
    
    override var resendCodeCompletable: Completable {
        RestAPIManager.instance.resendEmailCode().flatMapToCompletable()
    }
    
    override func resendButtonTapped() {
        guard KeychainManager.currentUser()?.email != nil else {
            try? KeychainManager.deleteUser()
            // Go back
            popToPreviousVC()
            return
        }
        
        // TODO: - AnalyticsManger
//        AnalyticsManger.shared.smsCodeResend()
        
        super.resendButtonTapped()
    }
    
    override func createVerificationRequest(code: UInt64) -> Completable {
        // TODO: - AnalyticsManger
//        AnalyticsManger.shared.smsCodeEntered()
        return RestAPIManager.instance.verifyEmail(code: code).flatMapToCompletable()
            .do(onError: { (error) in
                // TODO: - ANalyticsManager
                AnalyticsManger.shared.smsCodeError()
            }, onCompleted: {
                // TODO: - ANalyticsManager
                AnalyticsManger.shared.smsCodeRight()
            })
    }
}

//
//  VerifyEmailVC.swift
//  Commun
//
//  Created by Chung Tran on 3/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class VerifyEmailVC: BaseVerifyVC {
    override func setUp() {
        super.setUp()
        // TODO: - Analystic manager
//        AnalyticsManger.shared.registrationOpenScreen(3)
        
        subtitleLabel.text = "an email has been sent with the verification code. Please enter it here".localized().uppercaseFirst
        subtitleLabel.textColor = .a5a7bd
    }
    
    override func resendButtonTapped() {
        
    }
    
    override func sendCodeToVerify(_ code: UInt64) {
        
    }
}

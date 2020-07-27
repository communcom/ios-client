//
//  MyProfileVerifyContactVC.swift
//  Commun
//
//  Created by Chung Tran on 7/27/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileVerifyContactVC: BaseVerticalStackVC {
    // MARK: - Constants
    let contact: Contact
    
    // MARK: - Properties
    var resendTimer: Timer?
    var resendSeconds = 45
    
    // MARK: - Subviews
    lazy var resendButton = UIButton(labelFont: .systemFont(ofSize: 15, weight: .semibold))
    
    // MARK: - Initializers
    init(contact: Contact) {
        self.contact = contact
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        // Run timer
        resendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    // MARK: - Actions
    @objc func onTimerFires() {
        guard self.resendSeconds > 1 else {
            resendTimer?.invalidate()
            resendTimer = nil
            setResendButtonEnabled()
            return
        }
        
        resendSeconds -= 1
        setResendButtonEnabled(false)
    }
    
    private func setResendButtonEnabled(_ enabled: Bool = true) {
        if enabled {
            resendButton.isUserInteractionEnabled = true
            resendButton.setTitleColor(.appMainColor, for: .normal)
            resendButton.setTitle("resend verification code".localized().uppercaseFirst, for: .normal)
        } else {
            resendButton.isUserInteractionEnabled = false
            resendButton.setTitleColor(.appGrayColor, for: .normal)
            
            var time = ""
            time = " 0:\(String(describing: resendSeconds).addFirstZero())"
            resendButton.setTitle("code expires in".localized().uppercaseFirst + time, for: .normal)
        }
    }
}

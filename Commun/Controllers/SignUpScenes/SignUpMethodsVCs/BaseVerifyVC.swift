//
//  BaseVerifyVC.swift
//  Commun
//
//  Created by Chung Tran on 3/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import PinCodeInputView

class BaseVerifyVC: BaseSignUpVC, SignUpRouter {
    // MARK: - Constants
    let numberOfDigits = 4
    
    // MARK: - Properties
    private var counter = 0
    var resendTimer: Timer?
    var resendSeconds: Int = 0
    
    // MARK: - Subviews
    lazy var pinCodeInputView = PinCodeInputView<ItemView>(
        digit: numberOfDigits,
        itemSpacing: 12,
        itemFactory: {
            let itemView = ItemView()
            let autoTestMarker = String(format: "ConfirmUserPinCodeInputView-%i", self.counter)
            
            // For autotest
            itemView.accessibilityLabel = autoTestMarker
            itemView.accessibilityIdentifier = autoTestMarker
            self.counter += 1
            
            return itemView
    })
    
    lazy var resendButton = UIButton(labelFont: .systemFont(ofSize: 15, weight: .semibold))
    
    // MARK: - Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pinCodeInputView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deleteCode()
        pinCodeInputView.resignFirstResponder()
    }
    
    override func setUp() {
        super.setUp()
        checkResendSmsCodeTime()
    }
    
    override func setUpScrollView() {
        super.setUpScrollView()
        titleLabel.text = "verification".localized().uppercaseFirst
        
        // subtitle
        scrollView.contentView.addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        // pinCodeInputView
        pinCodeInputView.set { _ in
            self.verify()
        }
        
        pinCodeInputView.set(
            appearance: ItemAppearance(
                itemSize: CGSize(width: 48, height: 56),
                font: .systemFont(ofSize: 26),
                textColor: .black,
                backgroundColor: .f3f5fa,
                cursorColor: UIColor(red: 69 / 255, green: 108 / 255, blue: 1, alpha: 1),
                cornerRadius: 8)
        )
        
        pinCodeInputView.configureForAutoLayout()
        
        scrollView.contentView.addSubview(pinCodeInputView)
        pinCodeInputView.autoSetDimensions(to: CGSize(width: 228.0, height: 56.0))
        pinCodeInputView.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: 50)
        pinCodeInputView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // resend button
        scrollView.contentView.addSubview(resendButton)
        resendButton.autoPinEdge(.top, to: .bottom, of: pinCodeInputView, withOffset: 35)
        resendButton.autoAlignAxis(toSuperviewAxis: .vertical)
        resendButton.autoPinEdge(toSuperviewEdge: .bottom)
        
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
    }
    
    private func setResendButtonEnabled(_ enabled: Bool = true) {
        if enabled {
            resendButton.isUserInteractionEnabled = true
            resendButton.setTitleColor(.appMainColor, for: .normal)
            resendButton.setTitle("resend verification code".localized().uppercaseFirst, for: .normal)
        } else {
            resendButton.isUserInteractionEnabled = false
            resendButton.setTitleColor(.appGrayColor, for: .normal)
            resendButton.setTitle("resend verification code".localized().uppercaseFirst + " 0:\(String(describing: resendSeconds).addFirstZero())", for: .normal)
        }
    }
    
    // MARK: - Actions
    func checkResendSmsCodeTime() {
        guard let user = KeychainManager.currentUser(),
            user.registrationStep == .verify,
            let date = user.smsNextRetry
            else {
                setResendButtonEnabled()
                return
        }
        
        let dateNextSmsRetry = date.convert(toDateFormat: .nextSmsDateType)
        resendSeconds = Date().seconds(date: dateNextSmsRetry)
        
        // Run timer
        resendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
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
    
    @objc func resendButtonTapped() {}
    
    func verify() {
        guard pinCodeInputView.text.count == numberOfDigits,
            let code = UInt64(pinCodeInputView.text) else {
                return
        }
        sendCodeToVerify(code)
    }
    func sendCodeToVerify(_ code: UInt64) {}
    
    func deleteCode() {
        for _ in 0..<numberOfDigits {
            pinCodeInputView.deleteBackward()
        }
    }
}

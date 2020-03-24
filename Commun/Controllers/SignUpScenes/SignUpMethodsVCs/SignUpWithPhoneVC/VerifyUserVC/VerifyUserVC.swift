//
//  VerifyUserVC.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import PinCodeInputView

class VerifyUserVC: BaseSignUpVC, SignUpRouter {
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
    
    lazy var resendButton = UIButton(labelFont: .boldSystemFont(ofSize: 15))
    
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
        AnalyticsManger.shared.registrationOpenScreen(3)
        
        checkResendSmsCodeTime()
    }
    
    override func setUpScrollView() {
        super.setUpScrollView()
        titleLabel.text = "verification".localized().uppercaseFirst
        
        // subtitle
        subtitleLabel.text = "enter sms-code".localized().uppercaseFirst
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

        resendButton.setTitleColor(.appGrayColor, for: .disabled)
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
    }
    
    private func setResendButtonEnabled(_ enabled: Bool = true) {
        resendButton.isEnabled = enabled
        if enabled {
            resendButton.setTitle("resend verification code".localized().uppercaseFirst, for: .normal)
        } else {
            resendButton.setTitle("resend verification code".localized().uppercaseFirst + "0:\(String(describing: resendSeconds).addFirstZero())", for: .disabled)
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

        resendButton.isEnabled = false

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
    
    @objc func smsCodeButtonTapped(button: UIBarButtonItem) {
        pinCodeInputView.insertText(button.title!)
        removeAccessoryView()
    }
    
    @objc func resendButtonTapped() {
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
    
    func verify() {
       guard pinCodeInputView.text.count == ConfirmUserVC.numberOfDigits,
           let code = UInt64(pinCodeInputView.text) else {
               return
       }
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
    
    func deleteCode() {
        for _ in 0..<numberOfDigits {
            pinCodeInputView.deleteBackward()
        }
    }
    
    // MARK: - accessoryView
    func addAccessoryView(withSmsCode smsCode: String) {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: .adaptive(height: 44.0)))
        let smsCodeButton = UIBarButtonItem(title: smsCode, style: .plain, target: self, action: #selector(smsCodeButtonTapped(button:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [spacer, smsCodeButton, spacer]
        toolBar.tintColor = UIColor(hexString: "#6A80F5")
        pinCodeInputView.inputAccessoryView = toolBar
    }

    func removeAccessoryView() {
        pinCodeInputView.inputAccessoryView = nil
    }
}

//
//  VerifyPhoneVC.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import PinCodeInputView

class VerifyPhoneVC: BaseVerifyVC {
    private var counter = 0
    override var code: String {pinCodeInputView.text}
    
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
        
        subtitleLabel.text = "enter sms-code".localized().uppercaseFirst
        
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
    }
    
    override func setUpScrollView() {
        super.setUpScrollView()
        pinCodeInputView.configureForAutoLayout()
        
        scrollView.contentView.addSubview(pinCodeInputView)
        pinCodeInputView.autoSetDimensions(to: CGSize(width: 228.0, height: 56.0))
        pinCodeInputView.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: UIScreen.main.isSmall ? 20 : 50)
        pinCodeInputView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // resend button
        scrollView.contentView.addSubview(resendButton)
        resendButton.autoPinEdge(.top, to: .bottom, of: pinCodeInputView, withOffset: UIScreen.main.isSmall ? 16 : 35)
        resendButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // pin bottom
        resendButton.autoPinEdge(toSuperviewEdge: .bottom)
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
    
    override var verificationCompletable: Completable {
        AnalyticsManger.shared.smsCodeEntered()
        
        guard let code = UInt64(code) else {
            return Completable.error(CMError.registration(message: ErrorMessage.wrongVerificationCode.rawValue))
        }
        
        return RestAPIManager.instance.verify(code: code).flatMapToCompletable()
            .do(onError: { (error) in
                AnalyticsManger.shared.smsCodeError()
            }, onCompleted: {
                AnalyticsManger.shared.smsCodeRight()
            })
    }
    
    override func verify() {
        guard pinCodeInputView.text.count == numberOfDigits,
            let _ = UInt64(code) else {
                return
        }
        super.verify()
    }
    
    override func deleteCode() {
        for _ in 0..<numberOfDigits {
            pinCodeInputView.deleteBackward()
        }
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

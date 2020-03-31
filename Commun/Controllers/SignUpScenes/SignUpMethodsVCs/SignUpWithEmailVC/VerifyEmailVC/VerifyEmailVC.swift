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
    // MARK: - Properties
    override var code: String {textField.text ?? ""}
    
    // MARK: - Subviews
    lazy var textField = UITextField.signUpTextField(width: 290, placeholder: "verification code".localized().uppercaseFirst)
    
    // MARK: - Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deleteCode()
        textField.resignFirstResponder()
    }
    
    override func setUp() {
        super.setUp()
        // TODO: - Analystic manager
//        AnalyticsManger.shared.registrationOpenScreen(3)
        
        subtitleLabel.text = "an email has been sent with the verification code. Please enter it here".localized().uppercaseFirst
        subtitleLabel.textColor = .a5a7bd
    }
    
    override func bind() {
        super.bind()
        
    }
    
    override func setUpScrollView() {
        super.setUpScrollView()
        
        scrollView.contentView.addSubview(textField)
        textField.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: UIScreen.main.isSmall ? 20 : 50)
        textField.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // resend button
        scrollView.contentView.addSubview(resendButton)
        resendButton.autoPinEdge(.top, to: .bottom, of: textField, withOffset: UIScreen.main.isSmall ? 16 : 35)
        resendButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // pin bottom
        resendButton.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    override func viewDidSetUpScrollView() {
        setUpNextButton()
        nextButton.autoPinEdge(.top, to: .bottom, of: scrollView)
    }
    
    private func setUpNextButton() {
        view.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(nextButtonDidTouch), for: .touchUpInside)
        nextButton.autoAlignAxis(toSuperviewAxis: .vertical)
        let constant: CGFloat
        switch UIDevice.current.screenType {
        case .iPhones_5_5s_5c_SE:
            constant = 16
        default:
            constant = 40
        }
        
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: nextButton, attribute: .bottom, multiplier: 1.0, constant: constant)
        keyboardViewV.observeKeyboardHeight()
        view.addConstraint(keyboardViewV)
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
    
    override var verificationCompletable: Completable {
        // TODO: - AnalyticsManger
//        AnalyticsManger.shared.smsCodeEntered()
        return RestAPIManager.instance.verifyEmail(code: code).flatMapToCompletable()
            .do(onError: { (error) in
                // TODO: - ANalyticsManager
//                AnalyticsManger.shared.smsCodeError()
            }, onCompleted: {
                // TODO: - ANalyticsManager
//                AnalyticsManger.shared.smsCodeRight()
            })
    }
    
    override func verify() {
        guard !code.isEmpty && code.count == 6 else {
            showError(CMError.registration(message: ErrorMessage.wrongVerificationCode.rawValue))
            return
        }
        
        super.verify()
    }
    
    override func deleteCode() {
        textField.text = nil
    }
}

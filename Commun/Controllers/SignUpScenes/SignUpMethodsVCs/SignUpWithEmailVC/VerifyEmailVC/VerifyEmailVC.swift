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
    override var autoPinNextButtonToBottom: Bool {true}
    
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
        textField.delegate = self
        
        textField.rx.text.orEmpty
            .map {$0.count == 6}
            .bind(to: nextButton.rx.isDisabled)
            .disposed(by: disposeBag)
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
    
    override func nextButtonDidTouch() {
        verify()
    }
}

extension VerifyEmailVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        string.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
}

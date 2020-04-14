//
//  BaseVerifyVC.swift
//  Commun
//
//  Created by Chung Tran on 3/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class BaseVerifyVC: BaseSignUpVC, SignUpRouter {
    // MARK: - Constants
    let numberOfDigits = 4
    
    // MARK: - Properties
    var resendTimer: Timer?
    var resendSeconds: Int?
    var code: String {fatalError("must override")}
    
    // MARK: - Subviews
    lazy var resendButton = UIButton(labelFont: .systemFont(ofSize: 15, weight: .semibold))
    
    override func setUp() {
        super.setUp()
        titleLabel.text = "verification".localized().uppercaseFirst
        checkResendCodeTime()
        
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
    }
    
    override func setUpScrollView() {
        super.setUpScrollView()
        
        // subtitle
        scrollView.contentView.addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
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
            if let second = resendSeconds {
                time = " 0:\(String(describing: second).addFirstZero())"
            }
            resendButton.setTitle("resend verification code".localized().uppercaseFirst + time, for: .normal)
        }
    }
    
    // MARK: - Actions
    func getNextRetry() -> Date? {
        fatalError("must override")
    }
    
    func checkResendCodeTime() {
        guard let date = getNextRetry()
        else {
            setResendButtonEnabled()
            return
        }
        
        resendSeconds = Date().seconds(date: date)
        
        // Run timer
        resendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    @objc func onTimerFires() {
        guard self.resendSeconds ?? 0 > 1 else {
            resendTimer?.invalidate()
            resendTimer = nil
            setResendButtonEnabled()
            return
        }
        
        resendSeconds = (resendSeconds ?? 0) - 1
        setResendButtonEnabled(false)
    }
    
    var resendCodeCompletable: Completable {
        fatalError("Must override")
    }
    @objc func resendButtonTapped() {
        setResendButtonEnabled(false)
        resendCodeCompletable
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                self.setResendButtonEnabled()
                DispatchQueue.main.async {
                    self.checkResendCodeTime()
                    self.showAlert(title: "info".localized().uppercaseFirst,
                                   message: "successfully resend code".localized().uppercaseFirst)
                }
            }) { [weak self] (error) in
                self?.setResendButtonEnabled()
                self?.showError(error)
        }
        .disposed(by: disposeBag)
    }
    
    var verificationCompletable: Completable {
        fatalError("Must override")
    }
    
    func verify() {
        view.endEditing(true)
        showIndetermineHudWithMessage("verifying...".localized().uppercaseFirst)
        
        verificationCompletable
            .subscribe(onCompleted: { [weak self] in
                self?.view.endEditing(true)
                self?.hideHud()
                self?.signUpNextStep()
            }) { (error) in
                self.view.endEditing(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.deleteCode()
                    self.hideHud()
                    self.handleSignUpError(error: error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func deleteCode() {
        fatalError("Must override")
    }
}

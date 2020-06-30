//
//  ConfirmPasswordVC.swift
//  Commun
//
//  Created by Chung Tran on 3/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ConfirmPasswordVC: CreatePasswordVC {
    // MARK: - Properties
    var currentPassword: String
    
    // MARK: - Initializers
    init(currentPassword: String) {
        self.currentPassword = currentPassword
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.openReEnterPassword()
        titleLabel.text = "confirm password".localized().uppercaseFirst
        if !UIScreen.main.isSmall {
            let label = UILabel.with(text: "re-enter your password".localized().uppercaseFirst, textSize: 17)
            scrollView.contentView.addSubview(label)
            label.autoPinEdge(toSuperviewEdge: .top, withInset: 15)
            label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        }
    }
    
    override func setUpGenerateMasterPasswordButton() {
        // do nothing
    }
    
    override func backButtonDidTouch() {
        back()
    }
    
    override func validationDidComplete() {
        guard currentPassword == textField.text else {
            showErrorWithLocalizedMessage("passwords do not match")
            AnalyticsManger.shared.passwordConfirmed(available: false)
            return
        }

        AnalyticsManger.shared.passwordConfirmed(available: true)
        self.view.endEditing(true)
        showAttention()
    }

    private func showAttention() {
        AnalyticsManger.shared.openScreenAttention()
        showAttention(subtitle: "master password attention note".localized().uppercaseFirst,
                      descriptionText: "unfortunately, blockchain doesn’t allow us".localized().uppercaseFirst,
                      ignoreButtonLabel: "continue".localized().uppercaseFirst, ignoreAction: {
                            AnalyticsManger.shared.saveItMassterPassword()
                            self.sendData()
                        }, backAction: {
                            AnalyticsManger.shared.clickBackupAttention()
                            self.savePasswordToIcloud()
        })
    }

    private func sendData() {
        self.showIndetermineHudWithMessage("saving to blockchain")
        RestAPIManager.instance.toBlockChain(password: currentPassword)
            .subscribe(onCompleted: {
                AnalyticsManger.shared.passwordCreated()
                AuthManager.shared.reload()
            }) { (error) in
                self.hideHud()
                self.handleSignUpError(error: error)
            }
            .disposed(by: self.disposeBag)
    }

    // TODO: Create common func
    var backupAlert: UIAlertController?
    private func savePasswordToIcloud() {
        guard let userName = Config.currentUser?.name
        else {
            return
        }

        SecAddSharedWebCredential(URL.appDomain as CFString, userName as CFString, currentPassword as CFString) { [weak self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.backupAlert = self?.showAlert(title: "oops, we couldn’t save your password".localized().uppercaseFirst, message: "You need to enable Keychain, then".localized().uppercaseFirst, buttonTitles: ["retry".localized().uppercaseFirst, "cancel".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                        if index == 0 {
                            self?.savePasswordToIcloud()
                        }
                        self?.backupAlert?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self?.sendData()
                }
            }
        }
    }
}

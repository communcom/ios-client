//
//  SingUpWithPhoneVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import ReCaptcha

extension SignUpWithPhoneVC {
    @objc func chooseCountry() {
        if let countryVC = controllerContainer.resolve(SelectCountryVC.self) {
            self.view.endEditing(true)
            countryVC.bindViewModel(SelectCountryViewModel(withModel: self.viewModel))
            let nav = UINavigationController(rootViewController: countryVC)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func setupReCaptcha() -> ReCaptcha {
        let recaptcha = try! ReCaptcha(endpoint: ReCaptcha.Endpoint.default, locale: Locale(identifier: Locale.current.languageCode ?? "en"))

        #if DEBUG
        recaptcha.forceVisibleChallenge = false
        #endif

        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = reCaptchaTag
            self?.hideHud()
        }
        return recaptcha
    }
    
    func handleNextAction() {
        guard self.viewModel.validatePhoneNumber() else {
            self.showAlert(title: "error".localized().uppercaseFirst, message: "wrong phone number".localized().uppercaseFirst)
            return
        }
        AnalyticsManger.shared.PhoneNumberEntered()

        self.view.endEditing(true)

        self.showIndetermineHudWithMessage("signing you up".localized().uppercaseFirst + "...")

        self.setupReCaptcha().validate(on: view,
                                resetOnError: false,
                                completion: { [weak self] (result: ReCaptchaResult) in
                                    guard let strongSelf = self else { return }

                                    guard let captchaCode = try? result.dematerialize() else {
                                        print("XXX")
                                        return
                                    }

                                    print(captchaCode)
                                strongSelf.view.viewWithTag(reCaptchaTag)?.removeFromSuperview()

                                    let phone = strongSelf.viewModel.phone.value
                                    RestAPIManager.instance.firstStep(phone: phone, captchaCode: captchaCode)
                                        .subscribe(onSuccess: { _ in
                                            strongSelf.hideHud()
                                            strongSelf.signUpNextStep()
                                        }) { (error) in
                                            strongSelf.hideHud()
                                            strongSelf.handleSignUpError(error: error, with: strongSelf.viewModel.phone.value)
                                    }
                                    .disposed(by: strongSelf.disposeBag)
        })
    }
}

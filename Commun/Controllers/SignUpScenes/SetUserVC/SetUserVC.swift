//
//  SetUserVC.swift
//  Commun
//
//  Created by Chung Tran on 12/16/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SetUserVC: BaseViewController, SignUpRouter {
    // MARK: - Properties
    let viewModel = SetUserViewModel()
    
    // MARK: - Subviews
    lazy var backButton: UIButton = .back()
    lazy var textField: UITextField = {
        let alertButton = UIButton(width: 24, height: 24)
        alertButton.setImage(UIImage(named: "icon-info-button-default"), for: .normal)
        alertButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let rightView = UIView(width: 40, height: 56 * Config.heightRatio)
        rightView.addSubview(alertButton)
        alertButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        alertButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let tf = UITextField.signUpTextField(width: 290, placeholder: "username".localized().uppercaseFirst, rightView: rightView)
        return tf
    }()
    
    lazy var errorLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#F53D5B")!, numberOfLines: 0, textAlignment: .center)
    
    lazy var nextButton = CommunButton.default(height: 56, label: "next".localized().uppercaseFirst, cornerRadius: 8, isHuggingContent: false, isDisableGrayColor: true)
    
    // MARK: - Methods
    
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.registrationOpenScreen(4)
        self.title = "sign up".localized().uppercaseFirst
        self.navigationController?.navigationBar.prefersLargeTitles = true
        // backButton
        setLeftNavBarButton(with: backButton)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // label
        let label = UILabel.with(text: "create your username".localized().uppercaseFirst, textSize: 17)
        view.addSubview(label)
        label.autoPinTopAndLeadingToSuperViewSafeArea(inset: 20)
        
        // textfield
        view.addSubview(textField)
        textField.autoPinEdge(.top, to: .bottom, of: label, withOffset: 52 * Config.heightRatio)
        textField.autoPinEdge(toSuperviewEdge: .leading, withInset: 42 * Config.widthRatio)
        textField.autoPinEdge(toSuperviewEdge: .trailing, withInset: 42 * Config.widthRatio)
        
        view.addSubview(errorLabel)
        errorLabel.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 10)
        errorLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 32)
        errorLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 32)
        
        // button
        view.addSubview(nextButton)
        nextButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 42 * Config.widthRatio)
        nextButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 42 * Config.widthRatio)
        nextButton.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 16)
        nextButton.addTarget(self, action: #selector(buttonNextDidTouch(_:)), for: .touchUpInside)
        
        // dismiss keyboard
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // if username has already been set
        if KeychainManager.currentUser()?.registrationStep == .toBlockChain {
            signUpNextStep()
        }
    }
    
    override func bind() {
        super.bind()
        textField.rx.text.orEmpty
            .observeOn(MainScheduler.asyncInstance)
            .filter { text in
                if text.lowercased() == text {
                    return true
                }
                self.textField.text = text.lowercased()
                self.textField.sendActions(for: .valueChanged)
                return false
            }
            .map {self.viewModel.isUserNameValid($0)}
            .bind(to: nextButton.rx.isDisabled)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .bind(to: errorLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    @objc func backButtonTapped() {
        resetSignUpProcess()
    }
    
    @objc func infoButtonTapped() {
        AnalyticsManger.shared.userNameHelp()
        let userNameRulesView = UserNameRulesView(withFrame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 355.0), height: .adaptive(height: 386.0))))
        showCardWithView(userNameRulesView)
        
        userNameRulesView.completionDismissWithAction = { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func buttonNextDidTouch(_ sender: Any) {
        guard let userName = textField.text,
            viewModel.isUserNameValid(userName) else {
                return
        }

        AnalyticsManger.shared.userNameEntered()
        
        self.view.endEditing(true)
        
        if KeychainManager.currentUser()?.registrationStep == .toBlockChain {
            signUpNextStep()
            return
        }
        
        showIndetermineHudWithMessage("setting username".localized().uppercaseFirst + "...")
        
        RestAPIManager.instance.setUserName(userName)
            .flatMapToCompletable()
            .subscribe(onCompleted: {
                self.hideHud()
                self.signUpNextStep()
            }, onError: {error in
                self.hideHud()
                self.handleSignUpError(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

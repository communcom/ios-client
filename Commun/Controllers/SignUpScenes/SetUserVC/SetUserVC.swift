//
//  NewSetUserVC.swift
//  Commun
//
//  Created by Chung Tran on 3/31/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SetUserVC: BaseSignUpVC, SignUpRouter {
    // MARK: - Properties
    let viewModel = SetUserViewModel()
    
    // MARK: - Subviews
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
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.registrationOpenScreen(4)
        subtitleLabel.text = "create your username".localized().uppercaseFirst
        
        // if username has already been set
        if KeychainManager.currentUser()?.registrationStep == .toBlockChain {
            signUpNextStep()
        }
    }
    
    override func setUpScrollView() {
        super.setUpScrollView()
        
        // subtitle
        scrollView.contentView.addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        scrollView.contentView.addSubview(textField)
        textField.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: UIScreen.main.isSmall ? 20 : 50)
        textField.autoAlignAxis(toSuperviewAxis: .vertical)
        
        scrollView.contentView.addSubview(errorLabel)
        errorLabel.autoPinEdge(.top, to: .bottom, of: textField, withOffset: 10)
        errorLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 32)
        errorLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 32)
        
        errorLabel.autoPinEdge(toSuperviewEdge: .bottom)
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
    
    // MARK: - Actions
    @objc func infoButtonTapped() {
        AnalyticsManger.shared.userNameHelp()
        let userNameRulesView = UserNameRulesView(withFrame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 355.0), height: .adaptive(height: 386.0))))
        showCardWithView(userNameRulesView)
        
        userNameRulesView.completionDismissWithAction = { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func backButtonDidTouch() {
        resetSignUpProcess()
    }
    
    override func nextButtonDidTouch() {
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
}

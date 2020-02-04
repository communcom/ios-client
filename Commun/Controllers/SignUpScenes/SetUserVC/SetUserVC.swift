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
    lazy var textField: UITextField = {
        let tf = UITextField(height: 56 * Config.heightRatio, backgroundColor: .f3f5fa, cornerRadius: 12 * Config.heightRatio)
        tf.font = .systemFont(ofSize: 17 * Config.heightRatio)
        tf.keyboardType = .alphabet
        tf.placeholder = "username".localized().uppercaseFirst
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
        return tf
    }()
    
    lazy var errorLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#F53D5B")!, numberOfLines: 0, textAlignment: .center)
    
    lazy var nextButton = StepButton(height: 56 * Config.heightRatio, label: "next".localized().uppercaseFirst, labelFont: UIFont.boldSystemFont(ofSize: 17 * Config.heightRatio), backgroundColor: .appMainColor, textColor: .white, cornerRadius: 8)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        self.title = "sign up".localized().uppercaseFirst
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesBackButton = true
        
        // label
        let label = UILabel.with(text: "create your username".localized().uppercaseFirst, textSize: 17)
        view.addSubview(label)
        label.autoPinTopAndLeadingToSuperViewSafeArea(inset: 16)
        
        // textfield
        view.addSubview(textField)
        textField.autoPinEdge(.top, to: .bottom, of: label, withOffset: 52 * Config.heightRatio)
        textField.autoPinEdge(toSuperviewEdge: .leading, withInset: 42 * Config.widthRatio)
        textField.autoPinEdge(toSuperviewEdge: .trailing, withInset: 42 * Config.widthRatio)
        
        let leftView = UIView(width: 16, height: 56 * Config.heightRatio)
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        let alertButton = UIButton(width: 24, height: 24)
        alertButton.setImage(UIImage(named: "icon-info-button-default"), for: .normal)
        alertButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let rightView = UIView(width: 40, height: 56 * Config.heightRatio)
        rightView.addSubview(alertButton)
        alertButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        alertButton.autoAlignAxis(toSuperviewAxis: .vertical)
        textField.rightView = rightView
        textField.rightViewMode = .always
        
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
    }
    
    override func bind() {
        super.bind()
        textField.rx.text.orEmpty
            .map {self.viewModel.isUserNameValid($0)}
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .bind(to: errorLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    @objc func infoButtonTapped() {
        AnalyticsManger.shared.userNameHelp()
        let userNameRulesView = UserNameRulesView(withFrame: CGRect(origin: .zero, size: CGSize(width: CGFloat.adaptive(width: 355.0), height: CGFloat.adaptive(height: 386.0))))
        showCardWithView(userNameRulesView)
        
        userNameRulesView.completionDismissWithAction = {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func buttonNextDidTouch(_ sender: Any) {
        guard KeychainManager.currentUser()?.phoneNumber != nil else {
            resetSignUpProcess()
            return
        }
        
        guard let userName = textField.text,
            viewModel.isUserNameValid(userName) else {
                return
        }

        AnalyticsManger.shared.userNameEntered()
        
        self.view.endEditing(true)
        
        showIndetermineHudWithMessage("setting username".localized().uppercaseFirst + "...")
        
        viewModel.set(userName: userName)
            .catchError({ (error) -> Single<String> in
                if let error = error as? ErrorAPI {
                    if error.caseInfo.message == "Invalid step taken",
                        Config.currentUser?.registrationStep == .toBlockChain {
                        return .just(Config.currentUser?.id ?? "")
                    }
                }
                throw error
            })
            .flatMapCompletable({ (_) -> Completable in
                self.showIndetermineHudWithMessage("saving to blockchain...".localized().uppercaseFirst)
                return RestAPIManager.instance.toBlockChain()
            })
            .subscribe(onCompleted: {
                AppDelegate.reloadSubject.onNext(true)
            }, onError: {error in
                self.hideHud()
                self.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

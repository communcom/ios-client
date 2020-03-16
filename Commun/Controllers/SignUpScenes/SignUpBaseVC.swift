//
//  SignUpVC.swift
//  Commun
//
//  Created by Chung Tran on 3/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SignUpBaseVC: BaseViewController {
    // MARK: - Properties
    var termOfUseText: String {"By continuing, you agree to the Commun’s Terms of use, Privacy Policy and Blockchain Disclaimer".localized().uppercaseFirst}
    var alreadyHasAccountText: String {"already have an account? Sign in".localized().uppercaseFirst}
    
    // MARK: - Subviews
    lazy var backButton = UIButton.back(contentInsets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 15))
    lazy var titleLabel = UILabel.with(text: "sign up".localized().uppercaseFirst, textSize: 34, weight: .bold)
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    
    lazy var termOfUseLabel: UILabel = {
        let label = UILabel.with(textSize: 10, numberOfLines: 0, textAlignment: .center)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = .center
        let aStr = NSAttributedString(
            string: termOfUseText,
            attributes: [
                .foregroundColor: UIColor.a5a7bd,
                .font: UIFont.systemFont(ofSize: 10),
                .paragraphStyle: style
            ]
        )
            .applying(attributes: [.foregroundColor: UIColor.appMainColor], toOccurrencesOf: "terms of use, Privacy Policy".localized().uppercaseFirst)
            .applying(attributes: [.foregroundColor: UIColor.appMainColor], toOccurrencesOf: "blockchain Disclaimer".localized().uppercaseFirst)
        label.attributedString = aStr
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTermOfUseLabel(gesture:))))
        
        return label
    }()
    lazy var signInLabel: UILabel = {
        let label = UILabel.with(textSize: 15, textAlignment: .center)
        let aStr2 = NSAttributedString(
            string: alreadyHasAccountText,
            attributes: [.foregroundColor: UIColor.a5a7bd, .font: UIFont.systemFont(ofSize: 15)]
        )
            .applying(attributes: [.foregroundColor: UIColor.appMainColor], toOccurrencesOf: "sign in".localized().uppercaseFirst)
        label.attributedString = aStr2
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSignInLabel(gesture:))))
        return label
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        // title
        backButton.addTarget(self, action: #selector(backButtonDidTouch), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.autoPinTopAndLeadingToSuperViewSafeArea(inset: 10, xInset: 0)
        
        view.addSubview(titleLabel)
        switch UIDevice.current.screenType {
        case .iPhones_5_5s_5c_SE:
            titleLabel.autoPinEdge(.leading, to: .trailing, of: backButton, withOffset: 24)
            titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
        default:
            titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            titleLabel.autoPinEdge(.top, to: .bottom, of: backButton, withOffset: 10)
        }
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdge(toSuperviewEdge: .leading)
        scrollView.autoPinEdge(toSuperviewEdge: .trailing)
        scrollView.autoPinEdge(.top, to: .bottom, of: titleLabel)
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Actions
    @objc func tapTermOfUseLabel(gesture: UITapGestureRecognizer) {
        guard let text = termOfUseLabel.text else {return}

        let termsOfUseRange = (text as NSString).range(of: "terms of use, Privacy Policy".localized().uppercaseFirst)
        let blockChainDisclaimerRange = (text as NSString).range(of: "blockchain Disclaimer".localized().uppercaseFirst)

        if gesture.didTapAttributedTextInLabel(label: termOfUseLabel, inRange: termsOfUseRange) {
            load(url: "https://commun.com/doc/privacy")
        } else if gesture.didTapAttributedTextInLabel(label: termOfUseLabel, inRange: blockChainDisclaimerRange) {
            load(url: "https://commun.com/doc/disclaimer")
        }
    }
    
    @objc func tapSignInLabel(gesture: UITapGestureRecognizer) {
       guard let text = signInLabel.text else {return}
       AnalyticsManger.shared.goToSingIn()
       let signInRange = (text as NSString).range(of: "sign in".localized().uppercaseFirst)

       let nc = navigationController
       if gesture.didTapAttributedTextInLabel(label: signInLabel, inRange: signInRange) {
           navigationController?.popViewController(animated: true, {
               let signInVC = SignInVC()
               nc?.pushViewController(signInVC)
           })
       }
    }
    
    @objc func backButtonDidTouch() {
        back()
    }
    
}

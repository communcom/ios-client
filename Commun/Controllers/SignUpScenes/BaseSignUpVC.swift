//
//  BaseSignUpVC.swift
//  Commun
//
//  Created by Chung Tran on 3/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class BaseSignUpVC: BaseViewController {
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.hidden}
    
    // MARK: - Properties
    var termOfUseText: String {"by continuing, you agree to the".localized().uppercaseFirst}
    var alreadyHasAccountText: String {"already have an account? Sign in".localized().uppercaseFirst}
    var autoPinNextButtonToBottom: Bool {false}
    
    // MARK: - Subviews
    lazy var backButton = UIButton.back(contentInsets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 15))
    lazy var titleLabel = UILabel.with(text: "sign up".localized().uppercaseFirst, textSize: 34, weight: .bold)
    lazy var subtitleLabel = UILabel.with(textSize: 17, numberOfLines: 0)
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    
    lazy var errorLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#F53D5B")!, numberOfLines: 0, textAlignment: .center)
    
    lazy var termOfUseLabel: UILabel = {
        let label = UILabel.with(textSize: 10, numberOfLines: 0, textAlignment: .center)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = .center
        let aStr = NSAttributedString(
            string: termOfUseText,
            attributes: [
                .foregroundColor: UIColor.appGrayColor,
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
            attributes: [.foregroundColor: UIColor.appGrayColor, .font: UIFont.systemFont(ofSize: 15)]
        )
            .applying(attributes: [.foregroundColor: UIColor.appMainColor], toOccurrencesOf: "sign in".localized().uppercaseFirst)
        label.attributedString = aStr2
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSignInLabel(gesture:))))
        return label
    }()
    
    lazy var nextButton: CommunButton = {
        let button = CommunButton.default(height: 56, label: "next".localized().uppercaseFirst, cornerRadius: 8, isHuggingContent: false, isDisableGrayColor: true)
        button.autoSetDimension(.width, toSize: 290)
        button.addTarget(self, action: #selector(nextButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        // title
        backButton.addTarget(self, action: #selector(backButtonDidTouch), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.autoPinTopAndLeadingToSuperViewSafeArea(inset: 10, xInset: 0)
        
        view.addSubview(titleLabel)
        
        if UIScreen.main.isSmall {
            titleLabel.autoPinEdge(.leading, to: .trailing, of: backButton, withOffset: 24)
            titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: backButton)
        } else {
            titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            titleLabel.autoPinEdge(.top, to: .bottom, of: backButton, withOffset: 10)
        }
        
        // scrollView
        viewWillSetUpScrollView()
        
        setUpScrollView()
        
        viewDidSetUpScrollView()
        
        // dismiss keyboard
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    func viewWillSetUpScrollView() {
        
    }
    
    func setUpScrollView() {
        view.addSubview(scrollView)
        scrollView.autoPinEdge(toSuperviewEdge: .leading)
        scrollView.autoPinEdge(toSuperviewEdge: .trailing)
        scrollView.autoPinEdge(.top, to: .bottom, of: titleLabel)
    }
    
    func viewDidSetUpScrollView() {
        if autoPinNextButtonToBottom {
            setUpNextButton()
            nextButton.autoPinEdge(.top, to: .bottom, of: scrollView)
        } else {
            let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            keyboardViewV.observeKeyboardHeight()
            self.view.addConstraint(keyboardViewV)
        }
    }
    
    private func setUpNextButton() {
        view.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(nextButtonDidTouch), for: .touchUpInside)
        nextButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: nextButton, attribute: .bottom, multiplier: 1.0, constant: 16)
        keyboardViewV.observeKeyboardHeight()
        view.addConstraint(keyboardViewV)
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
       let signInRange = (text as NSString).range(of: "sign in".localized().uppercaseFirst)

       let nc = navigationController
       if gesture.didTapAttributedTextInLabel(label: signInLabel, inRange: signInRange) {
           navigationController?.popViewController(animated: true, {
               let signInVC = SignInVC()
               AnalyticsManger.shared.goToSignIn()
               nc?.pushViewController(signInVC)
           })
       }
    }
    
    @objc func backButtonDidTouch() {
        back()
    }
    
    @objc func nextButtonDidTouch() {}
}

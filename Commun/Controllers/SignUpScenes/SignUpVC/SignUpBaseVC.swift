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
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    
    lazy var termOfUseLabel: UILabel = {
        let label = UILabel.with(textSize: 10, numberOfLines: 0, textAlignment: .center)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = .center
        let aStr = NSAttributedString(
            string: "By clicking the “Sign up” button, you agree to the\nTerms of use, Privacy Policy and Blockchain Disclaimer".localized().uppercaseFirst,
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
            string: "do you have account? Sign in".localized().uppercaseFirst,
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
        title = "sign up".localized().uppercaseFirst
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
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
}

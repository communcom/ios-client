//
//  BaseSignUpMethodsVC.swift
//  Commun
//
//  Created by Chung Tran on 3/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class BaseSignUpMethodVC: BaseSignUpVC, SignUpRouter {
    override func setUpScrollView() {
        super.setUpScrollView()
        
        setUpInputViews()
        
        // term of use
        scrollView.contentView.addSubview(termOfUseLabel)
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        pinBottomOfInputViews()
        
        // next button
        scrollView.contentView.addSubview(nextButton)
        nextButton.autoPinEdge(.top, to: .bottom, of: termOfUseLabel, withOffset: 16)
        nextButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // sign in label
        scrollView.contentView.addSubview(signInLabel)
        signInLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        signInLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        signInLabel.autoPinEdge(.top, to: .bottom, of: nextButton, withOffset: 31)
        
        // pin bottom
        signInLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 31)
    }
    
    func setUpInputViews() {
        fatalError("must override")
    }
    
    func pinBottomOfInputViews() {
        fatalError("must override")
    }
}

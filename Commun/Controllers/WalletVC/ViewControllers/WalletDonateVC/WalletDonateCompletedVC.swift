//
//  WalletDonateCompletedVC.swift
//  Commun
//
//  Created by Chung Tran on 6/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WalletDonateCompletedVC: TransactionCompletedVC {
    var backButtonHandler: (() -> Void)?
    
    override func setUp() {
        super.setUp()
        backToWalletButton.setTitle("back".localized().uppercaseFirst, for: .normal)
    }
    
    override func setUpButtonStackView() {
        buttonStackView.addArrangedSubviews([backToWalletButton])
    }
    
    override func backToWalletButtonDidTouch() {
        backButtonHandler?()
    }
    
    override func stopBarButtonTapped(_ sender: UIBarButtonItem) {
        backButtonHandler?()
    }
}

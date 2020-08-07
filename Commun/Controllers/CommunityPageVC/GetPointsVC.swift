//
//  CommunityGetPointsVC.swift
//  Commun
//
//  Created by Chung Tran on 8/6/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class GetPointsVC: WalletSellCommunVC {
    var backButtonHandler: (() -> Void)?
    override func showCheck(transaction: Transaction) {
        let completedVC = GetPointsCompletedVC(transaction: transaction)
        completedVC.backButtonHandler = backButtonHandler
        self.show(completedVC, sender: nil)
    }
    
    override func changeMode() {
        // do nothing
    }
}

class GetPointsCompletedVC: TransactionCompletedVC {
    var backButtonHandler: (() -> Void)?
    override func setUp() {
        super.setUp()
        backToWalletButton.setTitle("back".localized().uppercaseFirst, for: .normal)
        title = "get points".localized().uppercaseFirst
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

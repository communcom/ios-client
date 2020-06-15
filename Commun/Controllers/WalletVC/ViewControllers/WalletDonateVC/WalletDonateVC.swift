//
//  WalletDonateVC.swift
//  Commun
//
//  Created by Chung Tran on 6/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WalletDonateVC: WalletSendPointsVC {
    // MARK: - Properties
    let initialAmount: Double?
    override var actionName: String {"donate"}
    
    // MARK: - Initilizers
    init(selectedBalanceSymbol symbol: String, user: ResponseAPIContentGetProfile?, amount: Double?) {
        self.initialAmount = amount
        super.init(selectedBalanceSymbol: symbol, user: user)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userView.isUserInteractionEnabled = false
    }
    
    override func balancesDidFinishLoading() {
        super.balancesDidFinishLoading()
        if let amount = initialAmount {
            pointsTextField.text = "\(amount)"
        }
    }
    
    override func keyboardWillHide() {
        super.keyboardWillHide()
        title = actionName.localized().uppercaseFirst
    }
}

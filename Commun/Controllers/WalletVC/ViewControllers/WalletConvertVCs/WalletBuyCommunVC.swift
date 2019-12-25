//
//  WalletBuyCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 12/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class WalletBuyCommunVC: WalletConvertVC {
    var currentBalance: ResponseAPIWalletGetBalance?
    
    override func setUp(with balances: [ResponseAPIWalletGetBalance]) {
        super.setUp(with: balances)
        
        if let balance = balances.first(where: {$0.symbol == self.currentSymbol}) {
            currentBalance =  balance
        } else {
            currentBalance = balances.first(where: {$0.symbol != "CMN"})
        }
        
        guard let balance = currentBalance else {return}
        balanceNameLabel.text = balance.name
        valueLabel.text = balance.balanceValue.currencyValueFormatted
    }
}

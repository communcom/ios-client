//
//  WalletBuyCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 12/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class WalletBuyCommunVC: WalletConvertVC {
    
    override func setUpCommunBalance() {
        
    }
    
    override func setUpCurrentBalance() {
        guard let balance = currentBalance else {return}
        balanceNameLabel.text = balance.name
        valueLabel.text = balance.balanceValue.currencyValueFormatted
    }
}

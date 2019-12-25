//
//  WalletBuyCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 12/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class WalletBuyCommunVC: WalletConvertVC {
    
    override func setUp() {
        super.setUp()
        buyNameLabel.text = "Commun"
        buyLogoImageView.image = UIImage(named: "tux")
        convertBuyLabel.text = "buy".localized().uppercaseFirst + " Commun"
    }
    
    override func setUpCommunBalance() {
        guard let balance = communBalance else {return}
        buyBalanceLabel.text = balance.balanceValue.currencyValueFormatted
    }
    
    override func setUpCurrentBalance() {
        guard let balance = currentBalance else {return}
        balanceNameLabel.text = balance.name
        valueLabel.text = balance.balanceValue.currencyValueFormatted
        convertSellLabel.text = "sell".localized().uppercaseFirst + " \(balance.name ?? balance.symbol)"
        rateLabel.text = "rate".localized().uppercaseFirst + ": 1 \(balance.name ?? balance.symbol) = \((1 / balance.priceValue).currencyValueFormatted) Commun"
    }
    
    override func buyValue(fromSellValue value: Double) -> Double {
        let price: Double? = self.currentBalance?.priceValue
        if price == 0 || price == nil {
            return 0
        }
        return value / price!
    }
    
    override func sellValue(fromBuyValue value: Double) -> Double {
        value * (self.currentBalance?.priceValue ?? 0)
    }
}

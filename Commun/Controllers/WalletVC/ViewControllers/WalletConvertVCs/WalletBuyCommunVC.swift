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
        super.setUpCommunBalance()
        guard let balance = communBalance else {return}
        buyBalanceLabel.text = balance.balanceValue.currencyValueFormatted
    }
    
    override func setUpCurrentBalance() {
        super.setUpCurrentBalance()
        guard let balance = currentBalance else {return}
        balanceNameLabel.text = balance.name
        valueLabel.text = balance.balanceValue.currencyValueFormatted
        convertSellLabel.text = "sell".localized().uppercaseFirst + " \(balance.name ?? balance.symbol)"
    }
    
    override func setUpPrice() {
        super.setUpPrice()
        rateLabel.attributedText = NSMutableAttributedString()
            .text("rate".localized().uppercaseFirst + ": 10 \(currentBalance?.symbol ?? currentBalance?.name ?? "") = \((viewModel.price.value != 0 ? 10 / viewModel.price.value : 0).currencyValueFormatted) CMN", size: 12, weight: .medium)
    }
    
    override func buyValue(fromSellValue value: Double) -> Double {
        let price = viewModel.price.value
        if price == 0 {
            return 0
        }
        return value / price * 10
    }
    
    override func sellValue(fromBuyValue value: Double) -> Double {
        value * viewModel.price.value / 10
    }
    
//    override func shouldEnableConvertButton() -> Bool {
//
//    }
}

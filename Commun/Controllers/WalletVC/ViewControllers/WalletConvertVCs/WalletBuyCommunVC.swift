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
    
    override func setUpBuyPrice() {
        
    }
    
    override func setUpSellPrice() {
        let value = NumberFormatter().number(from: sellTextField.text ?? "")?.doubleValue ?? 0
        
        rateLabel.attributedText = NSMutableAttributedString()
            .text("rate".localized().uppercaseFirst + ": \(value.currencyValueFormatted) \(currentBalance?.symbol ?? currentBalance?.name ?? "") = \((viewModel.buyPrice.value != 0 ? 10 / viewModel.buyPrice.value : 0).currencyValueFormatted) CMN", size: 12, weight: .medium)
    }
    
    override func getBuyPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: sellTextField.text ?? "")?.doubleValue
        else {return}
        viewModel.getSellPrice(quantity: "\(value) \(balance.symbol)")
    }
    
    override func getSellPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: buyTextField.text ?? "")?.doubleValue
        else {return}
        viewModel.getBuyPrice(symbol: balance.symbol, quantity: "\(value) CMN")
    }
    
//    override func shouldEnableConvertButton() -> Bool {
//
//    }
}

//
//  WalletBuyCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 12/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

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
        leftTextField.text = stringFromNumber(viewModel.buyPrice.value)
        
        let value = NumberFormatter().number(from: rightTextField.text ?? "")?.doubleValue ?? 0
        
        rateLabel.attributedText = NSMutableAttributedString()
            .text("rate".localized().uppercaseFirst + ": \(viewModel.buyPrice.value.currencyValueFormatted) \(currentBalance?.symbol ?? "") = \(value.currencyValueFormatted) CMN", size: 12, weight: .medium)
    }
    
    override func setUpSellPrice() {
        rightTextField.text = stringFromNumber(viewModel.sellPrice.value)
        
        let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue ?? 0

        rateLabel.attributedText = NSMutableAttributedString()
            .text("rate".localized().uppercaseFirst + ": \((viewModel.buyPrice.value != 0 ? 10 / viewModel.buyPrice.value : 0).currencyValueFormatted) \(currentBalance?.symbol ?? currentBalance?.name ?? "") = \(value.currencyValueFormatted) CMN", size: 12, weight: .medium)
    }
    
    override func bindBuyPrice() {
        rightTextField.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .subscribe(onNext: { (value) in
                if value == 0 {
                    self.viewModel.priceLoadingState.accept(.finished)
                    self.viewModel.buyPrice.accept(0)
                    return
                }
                self.getBuyPrice()
            })
            .disposed(by: disposeBag)
        
        viewModel.buyPrice
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.setUpBuyPrice()
            })
            .disposed(by: disposeBag)
    }
    
    override func bindSellPrice() {
        leftTextField.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .subscribe(onNext: { (value) in
                if value == 0 {
                    self.viewModel.priceLoadingState.accept(.finished)
                    self.viewModel.sellPrice.accept(0)
                    return
                }
                self.getSellPrice()
            })
            .disposed(by: disposeBag)
        
        viewModel.sellPrice
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.setUpSellPrice()
            })
            .disposed(by: disposeBag)
    }
    
    override func getBuyPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: rightTextField.text ?? "")?.doubleValue
        else {return}
        viewModel.getBuyPrice(symbol: balance.symbol, quantity: "\(value) CMN")
        
    }
    
    override func getSellPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue
        else {return}
        viewModel.getSellPrice(quantity: "\(value) \(balance.symbol)")
    }
    
    override func shouldEnableConvertButton() -> Bool {
        true
    }
}

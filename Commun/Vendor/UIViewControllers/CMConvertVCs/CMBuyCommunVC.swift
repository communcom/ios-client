//
//  CMBuyCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 9/22/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class CMBuyCommunVC: CMConvertVC {
    lazy var walletCarouselWrapper = WalletCarouselWrapper(height: 50)
    
    override func setUp() {
        super.setUp()
        // remove dropdown
        if let buyContainer = stackView.arrangedSubviews.first(where: {$0 is UIStackView}) as? UIStackView {
            buyContainer.removeArrangedSubview(buyContainer.arrangedSubviews.last!)
        }
        
        // add carousel
        topStackView.insertArrangedSubview(walletCarouselWrapper, at: 0)
        topStackView.setCustomSpacing(20, after: walletCarouselWrapper)
        
        buyNameLabel.text = "Commun"
        buyLogoImageView.image = UIImage(named: "tux")
        convertBuyLabel.text = "buy".localized().uppercaseFirst + " Commun"
        
        setRightBarButton(imageName: "wallet-right-bar-button", tintColor: .appWhiteColor, action: #selector(pointsListButtonDidTouch))

        walletCarouselWrapper.scrollingHandler = { index in
            self.currentBalance = self.viewModel.items.value[safe: index + 1]
        }
    }
    
    override func setUpCommunBalance() {
        super.setUpCommunBalance()
        
        guard let balance = communBalance else {return}
        
        buyBalanceLabel.text = balance.balanceValue.currencyValueFormatted
    }
    
    override func setUpCurrentBalance() {
        super.setUpCurrentBalance()
        
        guard let balance = currentBalance else { return }
        
        balanceNameLabel.attributedText = NSMutableAttributedString()
            .text("buy".localized().uppercaseFirst, size: 12, color: .appGrayColor)
            .text("\n")
            .text(balance.name ?? balance.symbol, size: 15, weight: .semibold)
        valueLabel.attributedText = NSMutableAttributedString()
            .text("balance".localized().uppercaseFirst, size: 12, color: .appGrayColor)
            .text("\n")
            .text(balance.balanceValue.currencyValueFormatted, size: 15, weight: .semibold)
        convertSellLabel.text = "sell".localized().uppercaseFirst + " \(balance.name ?? balance.symbol)"
    }
    
    override func setUpBuyPrice() {
        if let history = historyItem, !leftTextField.isFirstResponder {
            leftTextField.text = stringFromNumber(history.quantityValue)
        } else if viewModel.buyPrice.value > 0 {
            leftTextField.text = stringFromNumber(viewModel.buyPrice.value)
        }
        
        convertButton.isDisabled = !shouldEnableConvertButton()
    }
    
    override func setUpSellPrice() {
        if let history = historyItem, !leftTextField.isFirstResponder {
            rightTextField.text = stringFromNumber(history.meta.exchangeAmount!)
        } else {
            rightTextField.text = stringFromNumber(viewModel.sellPrice.value)
        }
        
        convertButton.isDisabled = !shouldEnableConvertButton()
    }
    
    override func setUpRate() {
        rateLabel.attributedText = NSMutableAttributedString()
            .text("rate".localized().uppercaseFirst + ": \(viewModel.rate.value.currencyValueFormatted) \(currentBalance?.symbol ?? "") = 10 CMN", size: 12, weight: .medium)
    }
    
    // MARK: - Binding
    override func bindItems() {
        super.bindItems()
        viewModel.items
            .map {$0.filter {$0.symbol != Config.defaultSymbol}}
            .subscribe(onNext: { (items) in
                self.walletCarouselWrapper.balances = items
                self.walletCarouselWrapper.currentIndex = items.firstIndex(where: {$0.symbol == self.currentSymbol}) ?? 0
                self.walletCarouselWrapper.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    override func bindBuyPrice() {
        rightTextField.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .subscribe(onNext: { (value) in
                if value == 0 {
                    self.viewModel.currentBuyPriceSymbol = nil
                    self.viewModel.currentBuyPriceQuantity = nil
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
                    self.viewModel.currentSellPriceQuantity = nil
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
    
    // MARK: - Helpers
    override func getBuyPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: rightTextField.text ?? "")?.doubleValue,
            value > 0
        else { return }
        viewModel.getBuyPrice(symbol: balance.symbol, quantity: "\(value) CMN")
    }
    
    override func getSellPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue,
            value > 0
        else { return }
       
        viewModel.getSellPrice(quantity: "\(value) \(balance.symbol)")
    }
    
     override func shouldEnableConvertButton() -> Bool {
        guard let sellAmount = NumberFormatter().number(from: self.leftTextField.text ?? "0")?.doubleValue else { return false }
        guard let currentBalance = self.currentBalance else { return false }
        guard sellAmount > 0 else { return false }
        
        if sellAmount > currentBalance.balanceValue {
            viewModel.errorSubject.accept(.insufficientFunds)
            
            return false
        }
        
        return true
    }
    
    // MARK: - Actions
    override func buyContainerDidTouch() {
        // do nothing
    }
    
    @objc func pointsListButtonDidTouch() {
        let vc = BalancesVC { balance in
            self.currentBalance = balance
                    
            let balanceIndex = self.viewModel.items.value.firstIndex(of: balance) ?? 0
            self.walletCarouselWrapper.scrollTo(itemAtIndex: balanceIndex == 0 ? 0 : balanceIndex - 1)
        }
        
        let nc = SwipeNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    override func actionButtonDidTouch() {
        guard checkValues() else { return }

        super.actionButtonDidTouch()
        
        guard var balance = currentBalance,
            var communBalance = communBalance,
            let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue
        else { return }
        
        let expectedValue = NumberFormatter().number(from: rightTextField.text ?? "")?.doubleValue
        
        showIndetermineHudWithMessage("selling".localized().uppercaseFirst + " \(balance.symbol)")
       
        BlockchainManager.instance.sellPoints(number: value, pointsCurrencyName: balance.symbol)
            .flatMapCompletable({ (transactionId) -> Completable in
                self.hideHud()
                
                if let expectedValue = expectedValue {
                    let newValue = balance.balanceValue - value
                    balance.balance = String(newValue)
                    balance.isWaitingForTransaction = true
                    balance.notifyChanged()
                    
                    let newCMNValue = communBalance.balanceValue + expectedValue
                    communBalance.balance = String(newCMNValue)
                    communBalance.isWaitingForTransaction = true
                    communBalance.notifyChanged()
                }

                let symbol: Symbol = Symbol(sell: balance.symbol, buy: Config.defaultSymbol)
                
                let transaction = Transaction(buyBalance: nil,
                                              sellBalance: nil,
                                              friend: nil,
                                              amount: CGFloat(expectedValue ?? 0),
                                              history: nil,
                                              actionType: "buy",
                                              symbol: symbol,
                                              operationDate: Date())
                
                self.showCheck(transaction: transaction)

                return RestAPIManager.instance.waitForTransactionWith(id: transactionId)
            })
            .subscribe(onCompleted: {
                balance.isWaitingForTransaction = false
                balance.notifyChanged()
                
                communBalance.isWaitingForTransaction = false
                communBalance.notifyChanged()
            }) { [weak self] (error) in
                self?.hideHud()
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
}

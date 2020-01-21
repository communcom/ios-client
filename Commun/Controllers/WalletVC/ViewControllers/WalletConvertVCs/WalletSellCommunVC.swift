//
//  WalletSellCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 12/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class WalletSellCommunVC: WalletConvertVC {
    // MARK: - Properties
    override var topColor: UIColor {
        .appMainColor
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        balanceNameLabel.text = "Commun"
        convertSellLabel.text = "sell".localized().uppercaseFirst + " Commun"
    }
    
    override func setUpCommunBalance() {
        super.setUpCommunBalance()
        guard let balance = communBalance else {return}
        valueLabel.text = balance.balanceValue.currencyValueFormatted
    }
    
    override func setUpCurrentBalance() {
        super.setUpCurrentBalance()
        guard let balance = currentBalance else {return}
        buyLogoImageView.setAvatar(urlString: balance.logo, namePlaceHolder: balance.name ?? balance.symbol)
        buyNameLabel.text = balance.name ?? balance.symbol
        buyBalanceLabel.text = balance.balanceValue.currencyValueFormatted
        convertBuyLabel.text = "buy".localized().uppercaseFirst + " \(balance.name ?? balance.symbol)"
    }
    
    override func setUpBuyPrice() {
        rightTextField.text = stringFromNumber(viewModel.buyPrice.value)
        convertButton.isEnabled = shouldEnableConvertButton()
    }
    
    override func setUpSellPrice() {
        if viewModel.sellPrice.value > 0 {
            leftTextField.text = stringFromNumber(viewModel.sellPrice.value)
        }
        
        convertButton.isEnabled = shouldEnableConvertButton()
    }
    
    override func layoutCarousel() {
        let communLogo = UIView.transparentCommunLogo(size: 50)
        scrollView.addSubview(communLogo)
        communLogo.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        communLogo.autoAlignAxis(toSuperviewAxis: .vertical)
        
        balanceNameLabel.autoPinEdge(.top, to: .bottom, of: communLogo, withOffset: 20)
    }
    
    override func layoutTrailingOfBuyContainer() {
        let dropdownButton = UIButton.circleGray(imageName: "drop-down")
        dropdownButton.addTarget(self, action: #selector(dropdownButtonDidTouch), for: .touchUpInside)
        buyContainer.addSubview(dropdownButton)
        dropdownButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        dropdownButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        dropdownButton.autoPinEdge(.leading, to: .trailing, of: buyBalanceLabel, withOffset: 10)
    }
    
    override func shouldEnableConvertButton() -> Bool {
        guard let sellAmount = NumberFormatter().number(from: self.leftTextField.text ?? "0")?.doubleValue
            else {return false}
        guard let communBalance = self.communBalance else {return false}
        guard sellAmount > 0 else {return false}
        if sellAmount > communBalance.balanceValue {
            viewModel.errorSubject.accept(.insufficientFunds)
            return false
        }
        return true
    }
    
    // MARK: - Binding
    override func bindBuyPrice() {
        leftTextField.rx.text.orEmpty
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
        rightTextField.rx.text.orEmpty
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
    
    override func bindRate() {
        viewModel.rate
            .subscribe(onNext: {[weak self] (value) in
                self?.rateLabel.attributedText = NSMutableAttributedString()
                    .text("rate".localized().uppercaseFirst + ": 10 CMN = \(value.currencyValueFormatted) \(self?.currentBalance?.symbol ?? "")", size: 12, weight: .medium)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc func dropdownButtonDidTouch() {
        let vc = BalancesVC(canChooseCommun: false) { (balance) in
            self.currentBalance = balance
        }
        let nc = BaseNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    override func getBuyPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue,
            value > 0
        else {return}
        viewModel.getBuyPrice(symbol: balance.symbol, quantity: "\(value) CMN")
    }
    
    override func getSellPrice() {
        guard let balance = currentBalance,
            let value = NumberFormatter().number(from: rightTextField.text ?? "")?.doubleValue,
            value > 0
        else {return}
        viewModel.getSellPrice(quantity: "\(value) \(balance.symbol)")
    }
    
    override func convertButtonDidTouch() {
        super.convertButtonDidTouch()
        
        guard let balance = currentBalance, let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue else { return }
                
        showIndetermineHudWithMessage("buying".localized().uppercaseFirst + " \(balance.symbol)")
         
        BlockchainManager.instance.buyPoints(communNumber: value, pointsCurrencyName: balance.symbol)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.hideHud()
                strongSelf.completion?()
                
                let transaction = Transaction(recipient: Recipient(id: balance.identity,
                                                                   name: balance.name!,
                                                                   avatarURL: balance.logo),
                                              operationDate: Date(),
                                              accuracy: 2,
                                              symbol: balance.symbol,
                                              amount: CGFloat(value * strongSelf.viewModel.rate.value / 10))

                let completedVC = TransactionCompletedVC(transaction: transaction)
                strongSelf.show(completedVC, sender: nil)
                strongSelf.hideHud()
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}

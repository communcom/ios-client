//
//  WalletBuyCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 12/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CircularCarousel

class WalletBuyCommunVC: WalletConvertVC {
    lazy var carousel = CircularCarousel(width: 300, height: 50)
    var carouselItems = [ResponseAPIWalletGetBalance]()
    
    override func setUp() {
        super.setUp()
        buyNameLabel.text = "Commun"
        buyLogoImageView.image = UIImage(named: "tux")
        convertBuyLabel.text = "buy".localized().uppercaseFirst + " Commun"
    }
    
    override func bind() {
        super.bind()
        viewModel.items
            .map {$0.filter {$0.symbol != "CMN"}}
            .subscribe(onNext: { (items) in
                self.carouselItems = items
                self.carousel.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    override func layoutCarousel() {
        carousel.delegate = self
        carousel.dataSource = self
        
        scrollView.addSubview(carousel)
        carousel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        carousel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        balanceNameLabel.autoPinEdge(.top, to: .bottom, of: carousel, withOffset: 20)
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
        
        convertButton.isEnabled = shouldEnableConvertButton()
    }
    
    override func setUpSellPrice() {
        rightTextField.text = stringFromNumber(viewModel.sellPrice.value)
        
        convertButton.isEnabled = shouldEnableConvertButton()
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
    
    override func bindRate() {
        viewModel.rate
            .subscribe(onNext: {[weak self] (value) in
                self?.rateLabel.attributedText = NSMutableAttributedString()
                    .text("rate".localized().uppercaseFirst + ": \(value.currencyValueFormatted) \(self?.currentBalance?.symbol ?? "") = 10 CMN", size: 12, weight: .medium)
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
        guard let sellAmount = NumberFormatter().number(from: self.leftTextField.text ?? "0")?.doubleValue
            else {return false}
        guard let currentBalance = self.currentBalance else {return false}
        guard sellAmount > 0 else {return false}
        if sellAmount > currentBalance.balanceValue {
            viewModel.errorSubject.accept(.insufficientFunds)
            return false
        }
        return true
    }
    
    override func convertButtonDidTouch() {
        super.convertButtonDidTouch()
        guard var balance = currentBalance,
            let value = NumberFormatter().number(from: leftTextField.text ?? "")?.doubleValue
        else {return}
        showIndetermineHudWithMessage("selling".localized().uppercaseFirst + " \(balance.symbol)")
        BlockchainManager.instance.sellPoints(number: value, pointsCurrencyName: balance.symbol)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                // TODO: - Show check
                self.completion?()
                self.back()
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}

extension WalletBuyCommunVC: CircularCarouselDataSource, CircularCarouselDelegate {
    func startingItemIndex(inCarousel carousel: CircularCarousel) -> Int {
        return (carouselItems.firstIndex(where: {$0.symbol == self.currentSymbol}) ?? 0)
    }
    
    func numberOfItems(inCarousel carousel: CircularCarousel) -> Int {
        return min(5, carouselItems.count)
    }
    
    func carousel(_: CircularCarousel, viewForItemAt indexPath: IndexPath, reuseView: UIView?) -> UIView {
        guard let balance = carouselItems[safe: indexPath.row] else {return UIView()}
        
        var view = reuseView

        if view == nil || view?.viewWithTag(1) == nil {
            view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            let imageView = MyAvatarImageView(size: 50)
            imageView.borderColor = .white
            imageView.borderWidth = 2
            imageView.tag = 1
            view!.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        
        let imageView = view?.viewWithTag(1) as! MyAvatarImageView
    
        imageView.setAvatar(urlString: balance.logo, namePlaceHolder: balance.name ?? balance.symbol)
        
        return view!
    }
    
    func carousel<CGFloat>(_ carousel: CircularCarousel, valueForOption option: CircularCarouselOption, withDefaultValue defaultValue: CGFloat) -> CGFloat {
        if option == .itemWidth {
            return CoreGraphics.CGFloat(50) as! CGFloat
        }
        
        if option == .spacing {
            return CoreGraphics.CGFloat(8) as! CGFloat
        }
        
        if option == .minScale {
            return CoreGraphics.CGFloat(0.7) as! CGFloat
        }
        
        return defaultValue
    }
    
    func carousel(_ carousel: CircularCarousel, willBeginScrollingToIndex index: Int) {
        currentBalance = viewModel.items.value[safe: index + 1]
    }
}

//
//  WalletSellCommunVC.swift
//  Commun
//
//  Created by Chung Tran on 12/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

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
    
    override func bind() {
        super.bind()
        sellTextField.rx.text.orEmpty
            .skip(1)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .map {$0 * (self.currentBalance?.priceValue ?? 0)}
            .map {self.stringFromNumber($0)}
            .subscribe(onNext: { (text) in
                self.buyTextField.text = text
            })
            .disposed(by: disposeBag)
        
        buyTextField.rx.text.orEmpty
            .skip(1)
            .map {NumberFormatter().number(from: $0)?.doubleValue ?? 0}
            .map {$0 / (self.currentBalance?.priceValue ?? 1)}
            .map {self.stringFromNumber($0)}
            .subscribe(onNext: { (text) in
                self.sellTextField.text = text
            })
            .disposed(by: disposeBag)
    }
    
    override func setUpCommunBalance() {
        guard let balance = communBalance else {return}
        valueLabel.text = balance.balanceValue.currencyValueFormatted
    }
    
    override func setUpCurrentBalance() {
        guard let balance = currentBalance else {return}
        buyLogoImageView.setAvatar(urlString: balance.logo, namePlaceHolder: balance.name ?? balance.symbol)
        buyNameLabel.text = balance.name ?? balance.symbol
        buyBalanceLabel.text = balance.balanceValue.currencyValueFormatted
        convertBuyLabel.text = "buy".localized().uppercaseFirst + " \(balance.name ?? balance.symbol)"
        rateLabel.text = "rate".localized().uppercaseFirst + ": 1 Commun = \(balance.priceValue.currencyValueFormatted) \(balance.name ?? balance.symbol)"
    }
    
    override func layoutCarousel() {
        let communLogo: UIView = {
            let view = UIView(width: 50, height: 50, backgroundColor: UIColor.white.withAlphaComponent(0.2), cornerRadius: 25)
            let slash = UIImageView(width: 8.04, height: 19.64, imageNamed: "slash")
            view.addSubview(slash)
            slash.autoCenterInSuperview()
            return view
        }()
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
    
    // MARK: - Actions
    @objc func dropdownButtonDidTouch() {
        
    }
}

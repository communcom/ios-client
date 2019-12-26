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
    
    override func setUpPrice() {
        super.setUpPrice()
        rateLabel.attributedText = NSMutableAttributedString()
            .text("rate".localized().uppercaseFirst + ": 10 CMN = \(viewModel.price.value.currencyValueFormatted) \(currentBalance?.symbol ?? "")", size: 12, weight: .medium)
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
    
    override func buyValue(fromSellValue value: Double) -> Double {
        value * viewModel.price.value / 10
    }
    
    override func sellValue(fromBuyValue value: Double) -> Double {
        let price = self.viewModel.price.value
        if price == 0 {
            return 0
        }
        return value / price * 10
    }
    
    override func shouldEnableConvertButton() -> Bool {
        guard let sellAmount = NumberFormatter().number(from: self.sellTextField.text ?? "0")?.doubleValue
            else {return false}
        guard let communBalance = self.communBalance else {return false}
        guard sellAmount > 0 else {return false}
        return sellAmount <= communBalance.balanceValue
    }
    
    // MARK: - Actions
    @objc func dropdownButtonDidTouch() {
        let vc = BalancesVC(canChooseCommun: false) { (balance) in
            self.currentBalance = balance
        }
        let nc = BaseNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
}

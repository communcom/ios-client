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
    
    // MARK: - Subviews
    lazy var convertButton = CommunButton.default(height: 50, label: "Convert", isHuggingContent: false)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        balanceNameLabel.text = "Commun"
        convertSellLabel.text = "sell".localized().uppercaseFirst + " Commun"
    }
    
    override func bind() {
        super.bind()
        
        // convert button
        Observable.merge(
            sellTextField.rx.text.orEmpty.skip(1).map {_ in ()},
            buyTextField.rx.text.orEmpty.skip(1).map {_ in ()}
        )
            .map { _ in
                guard let sellAmount = NumberFormatter().number(from: self.sellTextField.text ?? "0")?.doubleValue
                    else {return false}
                guard let communBalance = self.communBalance else {return false}
                guard sellAmount > 0 else {return false}
                return sellAmount <= communBalance.balanceValue
            }
            .bind(to: convertButton.rx.isEnabled)
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
    
    override func layoutBottom() {
        let warningLabel = UILabel.with(textSize: 12, weight: .medium, textColor: .a5a7bd, numberOfLines: 0, textAlignment: .center)
        warningLabel.attributedText = NSMutableAttributedString()
            .text("transfer time takes up to".localized().uppercaseFirst, size: 12, weight: .medium, color: .a5a7bd)
            .text(" 5-30 " + "minutes".localized().uppercaseFirst, size: 12, weight: .medium, color: .appMainColor)

        view.addSubview(warningLabel)
        warningLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        warningLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        convertButton.addTarget(self, action: #selector(convertButtonDidTouch), for: .touchUpInside)
        view.addSubview(convertButton)
        convertButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        convertButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        convertButton.autoPinEdge(.top, to: .bottom, of: warningLabel, withOffset: 20)
        
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: convertButton, attribute: .bottom, multiplier: 1.0, constant: 16)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        scrollView.autoPinEdge(.bottom, to: .top, of: warningLabel)
    }
    
    override func buyValue(fromSellValue value: Double) -> Double {
        value * (self.currentBalance?.priceValue ?? 0)
    }
    
    override func sellValue(fromBuyValue value: Double) -> Double {
        let price: Double? = self.currentBalance?.priceValue
        if price == 0 || price == nil {
            return 0
        }
        return value / price!
    }
    
    // MARK: - Actions
    @objc func dropdownButtonDidTouch() {
        let vc = BalancesVC(canChooseCommun: false) { (balance) in
            self.currentBalance = balance
        }
        let nc = BaseNavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func convertButtonDidTouch() {
        // TODO: - Convert
    }
}

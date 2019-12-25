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
    }
    
    override func setUp(with balances: [ResponseAPIWalletGetBalance]) {
        super.setUp(with: balances)
        guard let balance = balances.first(where: {$0.symbol == "CMN"}) else {return}
        valueLabel.text = balance.balanceValue.currencyValueFormatted
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
}

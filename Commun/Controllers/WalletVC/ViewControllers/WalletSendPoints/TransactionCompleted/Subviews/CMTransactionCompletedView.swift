//
//  CMTransactionCompletedView.swift
//  Commun
//
//  Created by Chung Tran on 4/2/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMTransactionCompletedView: MyView {
    let transaction: Transaction
    var isHistoryMode: Bool {
        !["buy", "sell", "send"].contains(transaction.actionType.rawValue)
    }
    var completionHome: (() -> Void)?
    var completionRepeat: (() -> Void)?
    var completionBackToWallet: (() -> Void)?
    
    lazy var buttonStackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    lazy var homeButton = UIButton(height: 56 * Config.heightRatio, label: "home".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .bold), backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), cornerRadius: 28 * Config.heightRatio)
    
    lazy var backToWalletButton = UIButton(height: 56 * Config.heightRatio, label: "back to wallet".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .bold), backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), textColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), cornerRadius: 28 * Config.heightRatio)
    lazy var repeatButton = UIButton(height: 56 * Config.heightRatio, label: "repeat".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .bold), backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), textColor: #colorLiteral(red: 0.416, green: 0.502, blue: 0.961, alpha: 1), cornerRadius: 28 * Config.heightRatio)

    lazy var transactionInfoView = CMTransactionInfoView(transaction: transaction)
    
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init(frame: .zero)
        
        defer {
            configureForAutoLayout()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        
        addSubview(buttonStackView)
        buttonStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        addSubview(transactionInfoView)
        transactionInfoView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        transactionInfoView.autoPinEdge(.bottom, to: .top, of: buttonStackView, withOffset: -34 * Config.heightRatio)
        
        buttonStackView.addArrangedSubviews(isHistoryMode ? [repeatButton] : [homeButton, backToWalletButton])
        
        homeButton.addTarget(self, action: #selector(homeButtonDidTouch), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(repeatsButtonDidTouch), for: .touchUpInside)
        backToWalletButton.addTarget(self, action: #selector(backToWalletButtonDidTouch), for: .touchUpInside)
    }
    
    @objc func homeButtonDidTouch() {
        completionHome?()
    }
    
    @objc func repeatsButtonDidTouch() {
        completionRepeat?()
    }
    
    @objc func backToWalletButtonDidTouch() {
        completionBackToWallet?()
    }
}

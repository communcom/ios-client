//
//  WalletDonateVC.swift
//  Commun
//
//  Created by Chung Tran on 6/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WalletDonateVC<T: ResponseAPIContentMessageType>: WalletSendPointsVC {
    // MARK: - Nested type
    class AmountButton: UIButton {
        var amount: CGFloat?
    }
    
    // MARK: - Properties
    var initialAmount: Double?
    override var actionName: String {"donate"}
    var message: T
    
    // MARK: - Subviews
    lazy var suggestedAmountButtons: [AmountButton] = [10, 100, 500, 1000].map {amount in
        let button = AmountButton(width: 64, height: 35, label: "+ \(amount)", labelFont: .systemFont(ofSize: 12, weight: .medium), backgroundColor: .appLightGrayColor, textColor: .appMainColor, cornerRadius: 35/2)
        button.amount = CGFloat(amount)
        button.addTarget(self, action: #selector(amountButtonDidTouch), for: .touchUpInside)
        return button
    }
    
    lazy var spacer = UIView.spacer(height: 1, backgroundColor: .clear)
    
    lazy var buyButton: UIButton = {
        let button = UIButton(height: 35, label: "+ " + "buy".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 12, weight: .medium), backgroundColor: .appLightGrayColor, textColor: .appMainColor, cornerRadius: 35/2, contentInsets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        button.addTarget(self, action: #selector(buyButtonDidTouch), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    // MARK: - Initilizers
    init(selectedBalanceSymbol symbol: String, user: ResponseAPIContentGetProfile, message: T, amount: Double?) {
        self.initialAmount = amount
        self.message = message
        super.init(selectedBalanceSymbol: symbol, user: user)
        
        memo = "donation for \(symbol):\(message.contentId.userId):\(message.contentId.permlink)"
        
        // observing
        T.observeItemChanged()
            .subscribe(onNext: { (post) in
                if post.identity == self.message.identity,
                    let newPost = self.message.newUpdatedItem(from: post)
                {
                    self.message = newPost
                }
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userView.isUserInteractionEnabled = false
    }
    
    override func configureBottomView() {
        super.configureBottomView()
        alertView.addArrangedSubviews(suggestedAmountButtons)
        alertView.addArrangedSubview(buyButton)
        alertView.addArrangedSubview(spacer)
        buyButton.isHidden = true
        alertLabel.isHidden = true
    }
    
    override func balancesDidFinishLoading() {
        dataModel.balances = dataModel.balances.filter {$0.balanceValue > 0}
        super.balancesDidFinishLoading()
        if let amount = initialAmount {
            initialAmount = nil
            programmaticallyChangeAmount(to: CGFloat(amount))
        }
    }
    
    override func keyboardWillHide() {
        super.keyboardWillHide()
        title = actionName.localized().uppercaseFirst
    }
    
    override func sendPointsDidComplete() {
        RestAPIManager.instance.getDonationsBulk(posts: [RequestAPIContentId(responseAPI: message.contentId)])
            .map {$0.items}
            .subscribe(onSuccess: { donations in
                guard let donation = donations.first(where: {$0.contentId == self.message.contentId}) else {return}
                self.message.donations = donation
                self.message.showDonationButtons = false
                self.message.notifyChanged()
            })
            .disposed(by: disposeBag)
        super.sendPointsDidComplete()
    }
    
    override func showCheck() {
        var transaction = dataModel.transaction
        if transaction.amount > 0 {
            transaction.amount = -transaction.amount
        }
        let completedVC = WalletDonateCompletedVC(transaction: transaction)
        completedVC.backButtonHandler = {
            completedVC.backCompletion {
                self.back()
            }
        }
        show(completedVC, sender: nil)
    }
    
    // MARK: - Actions
    override func createChooseBalancesVC() -> BalancesVC {
        BalancesVC(showEmptyBalances: false) { (balance) in
            self.handleBalanceChosen(balance)
        }
    }
    
    @objc func amountButtonDidTouch(_ button: UIButton) {
        guard let amount = (button as? AmountButton)?.amount else {return}
        programmaticallyChangeAmount(to: amount)
    }
    
    @objc func buyButtonDidTouch() {
        if dataModel.transaction.symbol.sell != "CMN" {
            // Sell CMN
            let vc = GetPointsVC(balances: dataModel.balances, symbol: dataModel.transaction.symbol.sell)
            vc.backButtonHandler = {
                self.dataModel.loadBalances { [weak self] success in
                    if success {
                        self?.balancesDidFinishLoading()
                        
                        
                    }
                }
                self.navigationController?.popToVC(type: Self.self)
            }
            self.show(vc, sender: nil)
        } else {
            // Buy CMN
            let vc = GetCMNVC(balances: dataModel.balances, symbol: dataModel.balances.first(where: {$0.balanceValue > 0 && $0.symbol != "CMN"})?.symbol)
            vc.backButtonHandler = {
                self.dataModel.loadBalances { [weak self] success in
                    if success {
                        self?.balancesDidFinishLoading()
                        self?.updateAlertView()
                    }
                }
                self.navigationController?.popToVC(type: Self.self)
            }
            self.show(vc, sender: nil)
        }
        
    }
    
    override func handleAmountValid() {
        super.handleAmountValid()
        suggestedAmountButtons.forEach {$0.isHidden = false}
        buyButton.isHidden = true
        spacer.isHidden = false
    }
    
    override func handleInsufficientFunds() {
        super.handleInsufficientFunds()
        suggestedAmountButtons.forEach {$0.isHidden = true}
        buyButton.isHidden = false
        spacer.isHidden = true
        
        alertLabel.text = "you don't have enough points for donation".localized().uppercaseFirst
    }
}

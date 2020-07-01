//
//  WalletDonateVC.swift
//  Commun
//
//  Created by Chung Tran on 6/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WalletDonateVC<T: ResponseAPIContentMessageType>: WalletSendPointsVC {
    // MARK: - Properties
    let initialAmount: Double?
    override var actionName: String {"donate"}
    var message: T
    
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
    
    override func balancesDidFinishLoading() {
        super.balancesDidFinishLoading()
        if let amount = initialAmount {
            pointsTextField.text = "\(amount)"
            pointsTextField.sendActions(for: .editingChanged)
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
}

//
//  WalletDonateVC.swift
//  Commun
//
//  Created by Chung Tran on 6/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WalletDonateVC: WalletSendPointsVC {
    // MARK: - Properties
    let initialAmount: Double?
    override var actionName: String {"donate"}
    var post: ResponseAPIContentGetPost
    
    // MARK: - Initilizers
    init(selectedBalanceSymbol symbol: String, user: ResponseAPIContentGetProfile, post: ResponseAPIContentGetPost, amount: Double?) {
        self.initialAmount = amount
        self.post = post
        super.init(selectedBalanceSymbol: symbol, user: user)
        
        memo = "donation for \(symbol):\(post.contentId.userId):\(post.contentId.permlink)"
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
        RestAPIManager.instance.getDonationsBulk(posts: [RequestAPIContentId(responseAPI: post.contentId)])
            .map {$0.items}
            .subscribe(onSuccess: { donations in
                guard let donation = donations.first(where: {$0.contentId == self.post.contentId}) else {return}
                self.post.donations = donation
                self.post.notifyChanged()
            })
            .disposed(by: disposeBag)
        super.sendPointsDidComplete()
    }
    
    override func showCheck() {
        let completedVC = WalletDonateCompletedVC(transaction: dataModel.transaction)
        completedVC.backButtonHandler = {
            completedVC.backCompletion {
                self.back()
            }
        }
        show(completedVC, sender: nil)
    }
}

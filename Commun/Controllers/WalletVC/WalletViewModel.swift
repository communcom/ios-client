//
//  WalletViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class WalletViewModel: TransferHistoryViewModel {
    // MARK: - Properties
    var initialBalances: [ResponseAPIWalletGetBalance]?
    var initialSubscriptionItems: [ResponseAPIContentGetSubscriptionsItem]?
    lazy var balancesVM = BalancesViewModel(balances: initialBalances)
    lazy var subscriptionsVM = SubscriptionsViewModel(type: .user, initialItems: initialSubscriptionItems)

    // MARK: - Initializers
    init(
        balances: [ResponseAPIWalletGetBalance]? = nil,
        subscriptions: [ResponseAPIContentGetSubscriptionsItem]? = nil,
        symbol: String
    ) {
        self.initialBalances = balances
        self.initialSubscriptionItems = subscriptions
        super.init(symbol: symbol)
        
        defer {
            subscriptionsVM.observeUserUnfollowed()
        }
    }
    
    override func reload(clearResult: Bool = true) {
        balancesVM.reload(clearResult: clearResult)
        subscriptionsVM.reload(clearResult: clearResult)
        super.reload(clearResult: clearResult)
    }
}

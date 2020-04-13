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
    lazy var balancesVM = BalancesViewModel.ofCurrentUser
    lazy var subscriptionsVM = SubscriptionsViewModel(type: .user)

    // MARK: - Initializers
    init(symbol: String) {
        super.init(symbol: symbol)
        
        defer {
            subscriptionsVM.observeUserUnfollowed()
            balancesVM.update()
        }
    }
    
    override func reload(clearResult: Bool = true) {
        balancesVM.update()
        subscriptionsVM.reload(clearResult: clearResult)
        super.reload(clearResult: clearResult)
    }
}

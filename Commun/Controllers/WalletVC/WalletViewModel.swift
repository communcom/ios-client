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
    lazy var balancesVM = BalancesViewModel()
    lazy var subscriptionsVM = SubscriptionsViewModel(type: .user)

    override func reload() {
        balancesVM.reload()
        subscriptionsVM.reload()
        super.reload()
    }
}

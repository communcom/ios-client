//
//  CMSendPointsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 9/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CMSendPointsViewModel: BaseViewModel {
    lazy var balancesVM = BalancesViewModel.ofCurrentUser
    let selectedBalance = BehaviorRelay<ResponseAPIWalletGetBalance?>(value: nil)
    let selectedReceiver = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    
    var balances: [ResponseAPIWalletGetBalance] { balancesVM.items.value }
    
    func selectBalanceAtIndex(index: Int) {
        selectedBalance.accept(balancesVM.items.value[safe: index])
    }
}

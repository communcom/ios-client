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
    // MARK: - Nested type
    enum Error: LocalizedError {
        case loadingBalanceError(Swift.Error?)
        case insufficientFunds
        case other(Swift.Error)
        var errorDescription: String? {
            switch self {
            case .loadingBalanceError(let error):
                return error?.localizedDescription
            case .insufficientFunds:
                return "insufficient funds".localized().uppercaseFirst
            case .other(let error):
                return error.localizedDescription
            }
        }
    }
    
    // MARK: - Properties
    lazy var balancesVM = BalancesViewModel.ofCurrentUser
    let selectedSymbol = BehaviorRelay<String?>(value: nil)
    let selectedReceiver = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    let error = BehaviorRelay<Error?>(value: nil)
    var memo = ""
    
    // MARK: - Getters
    var balances: [ResponseAPIWalletGetBalance] { balancesVM.items.value }
    var selectedBalance: ResponseAPIWalletGetBalance? { balances.first(where: {$0.symbol == selectedSymbol.value}) }
    
    // MARK: - Methods
    func reload(clearResult: Bool = false) {
        balancesVM.reload(clearResult: clearResult)
    }
    
    @discardableResult
    func check(amount: Double) -> Bool {
        guard let balance = selectedBalance?.balanceValue else {
            error.accept(.loadingBalanceError(nil))
            return false
        }
        
        if amount > balance {
            error.accept(.insufficientFunds)
            return false
        }
        
        error.accept(nil)
        return amount > 0 && selectedReceiver.value != nil
    }
}

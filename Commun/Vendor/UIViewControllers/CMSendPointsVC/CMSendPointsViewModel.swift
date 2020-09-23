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
    let selectedBalance = BehaviorRelay<ResponseAPIWalletGetBalance?>(value: nil)
    let selectedReceiver = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    let error = BehaviorRelay<Error?>(value: nil)
    
    // MARK: - Getters
    var balances: [ResponseAPIWalletGetBalance] { balancesVM.items.value }
    
    // MARK: - Methods
    override init() {
        super.init()
        defer {
            bind()
        }
    }
    
    func reload(clearResult: Bool = false) {
        balancesVM.reload(clearResult: clearResult)
    }
    
    func bind() {
        balancesVM.items
            .subscribe(onNext: { [weak self] (balances) in
                self?.selectedBalance.accept(balances.first(where: {$0.symbol == self?.selectedBalance.value?.symbol}))
            })
            .disposed(by: disposeBag)
    }
    
    func selectBalanceAtIndex(index: Int) {
        selectedBalance.accept(balancesVM.items.value[safe: index])
    }
    
    @discardableResult
    func check(amount: Double) -> Bool {
        guard let balance = selectedBalance.value?.balanceValue else {
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

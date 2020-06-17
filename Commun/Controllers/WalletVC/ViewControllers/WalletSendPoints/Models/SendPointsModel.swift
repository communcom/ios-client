//
//  SendPointModel.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 13.01.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import RxSwift
import Foundation

class SendPointsModel {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var balances = [ResponseAPIWalletGetBalance]()
    var transaction = Transaction()

    // MARK: - Custom Functions
    private func convert(balance: ResponseAPIWalletGetBalance?) -> Balance {
        return (name: balance?.name ?? balance?.symbol.fullName ?? "Commun", avatarURL: balance?.logo, amount: CGFloat(balance?.balanceValue ?? 0), symbol: balance?.symbol ?? "CMN")
    }
       
    func getBalance(bySymbol symbol: String = Config.defaultSymbol) -> Balance {
        guard balances.count > 0, let balance = balances.first(where: { $0.symbol == symbol }) else {
            return convert(balance: balances.first(where: {$0.symbol == "CMN"}))
        }
        
        return convert(balance: balance)
    }
    
    // For `isDisabled`
    func checkEnteredAmounts() -> Bool {
        guard abs(transaction.amount) > 0 else { return false }
        return abs(transaction.amount) <= getBalance(bySymbol: transaction.symbol.sell).amount
    }

    // For `isDisabled`
    func checkHistoryAmounts() -> Bool {
        guard abs(transaction.history?.quantityValue ?? 0) > 0 else { return true }
        return !(abs(CGFloat(transaction.history!.quantityValue)) <= getBalance().amount)
    }

    private func loadBalances(byUserID userID: String) -> Single<[ResponseAPIWalletGetBalance]> {
        return RestAPIManager.instance.getBalance(userId: userID).map{ $0.balances }
    }
    
    func loadBalances(completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Config.currentUser?.id else { completion(false); return }
        
        loadBalances(byUserID: currentUserID)
            .subscribe(onSuccess: { balances in
                self.balances = balances
                completion(true)
                },
                       onError: { _ in
                        completion(false)
            })
            .disposed(by: disposeBag)
    }
}

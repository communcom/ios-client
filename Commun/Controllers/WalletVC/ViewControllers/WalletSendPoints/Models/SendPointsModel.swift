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
    private func convert(balance: ResponseAPIWalletGetBalance) -> Balance {
        return (name: balance.name ?? balance.symbol.fullName, avatarURL: balance.logo, amount: CGFloat(balance.balanceValue), symbol: balance.symbol)
    }
       
    func getBalance(bySymbol symbol: String? = nil) -> Balance {
        let symbolValue = symbol ?? transaction.symbol
        return convert(balance: balances.first(where: { $0.symbol == symbolValue })!)
    }
    
    func checkEnteredAmounts() -> Bool {
        guard abs(transaction.amount) > 0 else { return false }
        return abs(transaction.amount) <= getBalance().amount
    }

    func checkHistoryAmounts() -> Bool {
        guard abs(transaction.history!.quantityValue) > 0 else { return false }
        return abs(CGFloat(transaction.history!.quantityValue)) <= getBalance().amount
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
                       onError: { error in
                        completion(false)
            })
            .disposed(by: disposeBag)
    }
}

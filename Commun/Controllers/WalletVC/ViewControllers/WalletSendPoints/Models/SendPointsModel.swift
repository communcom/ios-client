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
    var transaction = Transaction()
    var balances = [ResponseAPIWalletGetBalance]()
    
    var currentBalanceSymbol: String! {
        didSet {
            transaction.symbol = currentBalanceSymbol
        }
    }
    
    var currentBalance: Balance {
        get {
            return convert(balance: balances.first(where: { $0.symbol == currentBalanceSymbol })!)
        }
    }

    
    // MARK: - Class Initialization
    init(withSelectedBalanceSymbol symbol: String) {
        self.currentBalanceSymbol = symbol
    }


    // MARK: - Custom Functions
    private func convert(balance: ResponseAPIWalletGetBalance) -> Balance {
        var balanceInstance = Balance()
        balanceInstance.name = balance.name ?? balance.symbol.fullName
        balanceInstance.avatarURL = balance.logo
        balanceInstance.amount = CGFloat(balance.balanceValue)
        transaction.accuracy = transaction.amount == 0 ? 0 : (transaction.amount >= 1_000.0 ? 2 : 4)
        
        return balanceInstance
    }
        
    func checkEnteredAmounts() -> Bool {
        guard abs(transaction.amount) > 0 else { return false }
        return abs(transaction.amount) <= currentBalance.amount
    }

    func checkHistoryAmounts() -> Bool {
        guard abs(transaction.history!.quantityValue) > 0 else { return false }
        return abs(CGFloat(transaction.history!.quantityValue)) <= currentBalance.amount
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

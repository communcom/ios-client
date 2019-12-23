//
//  BalancesListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class BalancesListFetcher: ListFetcher<ResponseAPIWalletGetBalance> {
    // MARK: - Properties
    var userId: String
    
    // MARK: - Methods
    init(userId: String?) {
        self.userId = userId ?? Config.currentUser?.id ?? ""
    }
    
    override var request: Single<[ResponseAPIWalletGetBalance]> {
        RestAPIManager.instance.getBalance(userId: userId)
            .map {$0.balances}
    }
    
    override func join(newItems items: [ResponseAPIWalletGetBalance]) -> [ResponseAPIWalletGetBalance] {
        var balances = super.join(newItems: items)
        if let cmnIndex = balances.firstIndex(where: {$0.symbol == "CMN"}) {
            if cmnIndex > 0 {
                let element = balances[cmnIndex]
                balances.remove(at: cmnIndex)
                balances.insert(element, at: 0)
            }
        } else {
            balances.insert(ResponseAPIWalletGetBalance(symbol: "CMN", balance: "0", logo: nil, name: nil, frozen: nil, price: nil), at: 0)
        }
        
        return balances
    }
}

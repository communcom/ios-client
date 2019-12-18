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
    init(userId: String) {
        self.userId = userId
    }
    
    override var request: Single<[ResponseAPIWalletGetBalance]> {
        // TODO: - Delete mock, replace by real request
        ResponseAPIWalletGetBalances.singleWithMockData()
            .map {$0.balances}
            .delay(0.8, scheduler: MainScheduler.instance)
    }
}

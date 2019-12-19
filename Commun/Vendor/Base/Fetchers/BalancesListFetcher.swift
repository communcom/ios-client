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
}

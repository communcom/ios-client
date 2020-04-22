//
//  BalancesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxCocoa

class BalancesViewModel: ListViewModel<ResponseAPIWalletGetBalance> {
    let searchResult = BehaviorRelay<[ResponseAPIWalletGetBalance]?>(value: nil)
    
    static var ofCurrentUser = BalancesViewModel()
    
    convenience init(userId: String? = nil) {
        let fetcher = BalancesListFetcher(userId: userId)
        self.init(fetcher: fetcher)
        defer {
            fetchNext()
        }
    }
    
    func update() {
        reload(clearResult: false)
    }
}

//
//  BalancesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class BalancesViewModel: ListViewModel<ResponseAPIWalletGetBalance> {
    convenience init(userId: String) {
        let fetcher = BalancesListFetcher(userId: userId)
        self.init(fetcher: fetcher)
    }
}
